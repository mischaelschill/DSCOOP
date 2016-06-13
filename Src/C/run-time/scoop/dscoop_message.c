#include "rt_dscoop.h"
#include "rt_assert.h"
#include "eif_internal.h"
#include <sys/socket.h>
#include "eif_dscoop.h"
#include "rt_processor.h"
#include "eif_globals.h"
#include <math.h>
#include <endian.h>
#include <sys/param.h>
#include "rt_gen_types.h"
#include "rt_dscoop_message.h"
#include "rt_struct.h"
#include "rt_cecil.h"
#include "rt_macros.h"

const char BOOLEAN_type_name[] = "BOOLEAN";
const char INTEGER_8_type_name[] = "INTEGER_8";
const char INTEGER_16_type_name[] = "INTEGER_16";
const char INTEGER_32_type_name[] = "INTEGER_32";
const char INTEGER_64_type_name[] = "INTEGER_64";
const char NATURAL_8_type_name[] = "NATURAL_8";
const char NATURAL_16_type_name[] = "NATURAL_16";
const char NATURAL_32_type_name[] = "NATURAL_32";
const char NATURAL_64_type_name[] = "NATURAL_64";
const char REAL_32_type_name[] = "REAL_32";
const char REAL_64_type_name[] = "REAL_64";
const char CHARACTER_8_type_name[] = "CHARACTER_8";
const char CHARACTER_32_type_name[] = "CHARACTER_32";

const char ESTRING_8_type_name[] = "ESTRING_8";
const char ESTRING_32_type_name[] = "ESTRING_32";
const char STRING_8_type_name[] = "STRING_8";
const char STRING_32_type_name[] = "STRING_32";

extern EIF_BOOLEAN eif_dscoop_print_debug_messages;

#pragma pack(push,1)

struct eif_dscoop_message_header
{
	// These variables are stored in network order (big endian)!
	EIF_NATURAL_8 version; // Current version is 1
	EIF_NATURAL_16 flags;
	EIF_NATURAL_64 sender;
	EIF_NATURAL_64 recipient;
	EIF_NATURAL_8 subject;
	EIF_NATURAL_32 id;
	EIF_NATURAL_32 length; // length of the following content
};
#pragma pack(pop)


#define DSCOOP_MESSAGE_HEADER_SIZE sizeof(struct eif_dscoop_message_header)

static inline EIF_BOOLEAN is_string_safe(struct eif_dscoop_message* msg, char * str) {
	EIF_NATURAL_64 maxlen = msg->length - (EIF_NATURAL_64)((size_t)str - (size_t)msg->data.raw);
	return strnlen (str, maxlen) < maxlen;
}

size_t str32len(const EIF_NATURAL_32 string[]) {
	size_t result = 0;
	while (string[result] > 0) {
		result ++;
	}
	return result;
}

EIF_REAL_32 ber32toh (const EIF_REAL_32 input)
{
	EIF_NATURAL_32* in = (EIF_NATURAL_32*) & input;
	EIF_NATURAL_32 out;
	out = be32toh (*in);
	EIF_REAL_32* result = (EIF_REAL_32*) & out;
	return *result;
}

EIF_REAL_32 htober32 (const EIF_REAL_32 input)
{
	return ber32toh (input);
}

//EIF_REAL_64 ber64toh (const EIF_REAL_64 input)
//{
//	EIF_NATURAL_64* in = (EIF_NATURAL_64*) & input;
//	EIF_NATURAL_64 out;
//	out = be64toh (*in);
//	EIF_REAL_64* result = &out;
//	return *result;
//}
//
//EIF_REAL_64 htober64 (const EIF_REAL_64 input)
//{
//	return ber64toh (input);
//}

rt_public EIF_NATURAL_32 eif_dscoop_message_generate_id ()
{
	static volatile EIF_NATURAL_32 messageid_counter = 0;
	EIF_NATURAL_32 id, old_id;

	do {
		old_id = messageid_counter;
		id = old_id + 1;
		if (id == 0)
			id++;
		// TODO: Make this platform independent
	} while (!__sync_bool_compare_and_swap (&messageid_counter, old_id, id));

	return id;
}

void eif_dscoop_message_allocate (struct eif_dscoop_message* msg)
{
	msg->capacity = sizeof (struct eif_dscoop_message_header) * 2;
	msg->data.raw = malloc (msg->capacity);
	msg->anchor = NULL;
	msg->length = DSCOOP_MESSAGE_HEADER_SIZE;
	msg->arg_count = 0;
	ENSURE ("allocated", msg->data.raw);
}

void eif_dscoop_message_init (struct eif_dscoop_message* msg, enum eif_dscoop_message_subject subject, EIF_NATURAL_64 recipient)
{
	eif_dscoop_message_allocate (msg);
	eif_dscoop_message_reset (msg, subject, recipient);
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
}

int eif_dscoop_message_add_index (struct eif_dscoop_message *msg, EIF_NATURAL_32 item_size)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	msg->index[msg->arg_count++] = msg->length;
	msg->length += item_size;
	msg->data.header->length = htobe32 (be32toh (msg->data.header->length) + item_size);
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return T_OK;
}

int eif_dscoop_message_accommodate (struct eif_dscoop_message *msg, EIF_NATURAL_64 space)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	while (msg->length + space > msg->capacity) {
		struct eif_dscoop_message_header* old_data = msg->data.header;
		msg->data.raw = malloc (msg->capacity * 2);
		if (!msg->data.raw) {
			msg->data.header = old_data;
			return T_NO_MORE_MEMORY;
		}
		memcpy (msg->data.raw, old_data, msg->length);
		msg->capacity *= 2;
		free (old_data);
	}
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return T_OK;
}

#pragma pack(push,1)

struct eif_dscoop_message_str8_arg
{
	EIF_NATURAL_8 type;
	char data[1];
};

struct eif_dscoop_message_str32_arg
{
	EIF_NATURAL_8 type;
	EIF_NATURAL_32 data[1];
};

struct eif_dscoop_message_natural_arg
{
	EIF_NATURAL_8 type;
	EIF_NATURAL_64 value;
};

struct eif_dscoop_message_ref_arg
{
	EIF_NATURAL_8 type;
	EIF_NATURAL_64 nid;
	EIF_NATURAL_32 pid;
	EIF_NATURAL_32 oid;
	char reftype[1];
};

struct eif_dscoop_message_node_arg
{
	EIF_NATURAL_8 type;
	EIF_NATURAL_64 nid;
	EIF_NATURAL_16 port;
	char address[1];
};

struct eif_dscoop_message_agent_arg
{
	EIF_NATURAL_8 type;
	EIF_NATURAL_32 arguments_count;
	char class_feature_name[1];
};

struct rt_dscoop_message_object_arg
{
	EIF_NATURAL_8 type;
	EIF_NATURAL_16 field_count;
	char class_name[1];
};
#pragma pack(pop)

int eif_dscoop_message_add_node_argument (struct eif_dscoop_message *msg, EIF_NATURAL_64 nid, char *address, EIF_NATURAL_16 port)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	size_t len = strlen (address);
	EIF_NATURAL_64 required_space = sizeof (struct eif_dscoop_message_node_arg) + len;
	enum eif_dscoop_message_arg_type type = A_NODE;

	int error = eif_dscoop_message_accommodate (msg, required_space);
	if (error) {
		return error;
	}
	struct eif_dscoop_message_node_arg* arg =
			(struct eif_dscoop_message_node_arg*) (msg->data.raw + msg->length);
	arg->type = (EIF_NATURAL_8) type;
	arg->nid = htobe64 (nid);
	arg->port = htobe16 (port);
	strcpy (arg->address, address);

	//Update the index and length
	eif_dscoop_message_add_index (msg, required_space);
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return T_OK;
}

int eif_dscoop_message_add_identifier_argument (struct eif_dscoop_message *msg, const char * ident)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	EIF_NATURAL_64 required_space = sizeof (struct eif_dscoop_message_str8_arg) + strlen (ident);
	enum eif_dscoop_message_arg_type type = A_IDENT;

	int error = eif_dscoop_message_accommodate (msg, required_space);
	if (error) {
		return error;
	}
	struct eif_dscoop_message_str8_arg* arg =
			(struct eif_dscoop_message_str8_arg*) (msg->data.raw + msg->length);
	arg->type = (EIF_NATURAL_8) type;
	strcpy (arg->data, ident);

	//Update the index and length
	eif_dscoop_message_add_index (msg, required_space);
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return T_OK;
}

int eif_dscoop_message_add_natural_argument (struct eif_dscoop_message *msg, EIF_NATURAL_64 value)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	EIF_NATURAL_64 required_space = sizeof (struct eif_dscoop_message_natural_arg);
	enum eif_dscoop_message_arg_type type = A_NIDENT;

	int error = eif_dscoop_message_accommodate (msg, required_space);
	if (error) {
		return error;
	}
	struct eif_dscoop_message_natural_arg* arg =
			(struct eif_dscoop_message_natural_arg*) (msg->data.raw + msg->length);

	arg->type = (EIF_NATURAL_8) type;
	arg->value = htobe64 (value);

	//Update the index and length
	eif_dscoop_message_add_index (msg, required_space);
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return T_OK;
}

size_t rt_dscoop_message_reference_space (EIF_OBJECT ref)
{
	char* reftype = *ref ? eif_typename (eif_new_type (Dftype (*ref), ATTACHED_FLAG)) + 1
			: "NONE";

	return sizeof (struct eif_dscoop_message_ref_arg) + strlen (reftype);
}

size_t rt_dscoop_message_object_space (EIF_OBJECT ref)
{
	char* reftype = *ref ? eif_typename (eif_new_type (Dftype (*ref), ATTACHED_FLAG)) + 1
			: "NONE";

	return sizeof (struct rt_dscoop_message_object_arg) + strlen (reftype);
}

size_t rt_dscoop_message_extend_value_internal 
		(struct eif_dscoop_message* message, EIF_TYPED_VALUE* arg);

size_t rt_dscoop_message_extend_object (struct eif_dscoop_message *msg, EIF_OBJECT obj)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	
	EIF_ENCODED_TYPE dftype = Dftype (eif_access (obj));
	EIF_TYPE type = eif_decoded_type (dftype);

	char* reftype = eif_access (obj) ? eif_typename (eif_new_type (dftype, ATTACHED_FLAG)) + 1
			: "NONE";

	EIF_NATURAL_64 required_space = sizeof (struct rt_dscoop_message_object_arg) + strlen (reftype);

	if (eif_dscoop_message_accommodate (msg, required_space)) {
		return 0;
	}

	struct rt_dscoop_message_object_arg* arg =
			(struct rt_dscoop_message_object_arg*) (msg->data.raw + msg->length);
	arg->type = (EIF_NATURAL_8) A_OBJ;

	strcpy (arg->class_name, reftype);
	
	arg->field_count = ei_count_field_of_type (dftype);
	
	for (EIF_NATURAL_16 i = 0; i < arg->field_count; i++) {
		eif_dscoop_message_add_identifier_argument (msg, ei_field_name_of_type (i, dftype));
		EIF_TYPED_VALUE typed_val;
		EIF_TYPE field_type = eif_decoded_type (System(To_dtype(type.id)).cn_types[i]);
		typed_val.type = eif_dtype_to_sk_type (To_dtype(field_type.id));
		switch (typed_val.type) {
			case SK_REF: 
				{
					EIF_REFERENCE ref = ei_reference_field (i, eif_access (obj));
					typed_val.item.r = ref;
					if (EIF_IS_EXPANDED_TYPE(System(eif_decoded_type (Dftype (ref)).id))) {
						typed_val.type = SK_EXP;
					} else if (!RT_CONF_IS_SEPARATE_FLAG(field_type.annotations)) {
						// A reference object attached to a non-separate field.
						// TODO: Set this to SK_EXP to export the object transparently
						typed_val.type = SK_VOID;
						typed_val.item.r = NULL;
					}
				}
				break;
			case SK_CHAR8: 
				typed_val.item.c1 = ei_char_field (i, eif_access (obj));
				break;
			case SK_CHAR32: 
				typed_val.item.c4 = ei_char_32_field (i, eif_access (obj));
				break;
			case SK_BOOL: 
				typed_val.item.b = ei_bool_field (i, eif_access (obj));
				break;
			case SK_UINT8: 
				typed_val.item.n1 = ei_uint_8_field (i, eif_access (obj));
				break;
			case SK_UINT16: 
				typed_val.item.n2 = ei_uint_16_field (i, eif_access (obj));
				break;
			case SK_UINT32: 
				typed_val.item.n4 = ei_uint_32_field (i, eif_access (obj));
				break;
			case SK_UINT64: 
				typed_val.item.n8 = ei_uint_64_field (i, eif_access (obj));
				break;
			case SK_INT8: 
				typed_val.item.i1 = ei_int_8_field (i, eif_access (obj));
				break;
			case SK_INT16: 
				typed_val.item.i2 = ei_int_16_field (i, eif_access (obj));
				break;
			case SK_INT32: 
				typed_val.item.i4 = ei_int_32_field (i, eif_access (obj));
				break;
			case SK_INT64: 
				typed_val.item.i8 = ei_int_64_field (i, eif_access (obj));
				break;
			case SK_REAL32: 
				typed_val.item.r4 = ei_float_field (i, eif_access (obj));
				break;
			case SK_REAL64: 
				typed_val.item.r8 = ei_double_field (i, eif_access (obj));
				break;
			case SK_EXP: 
				typed_val.item.r = ei_oref(i, eif_access (obj));
				break;
			case SK_POINTER: 
				typed_val.item.p = ei_ptr_field (i, eif_access (obj));
				break;
		}
		
		rt_dscoop_message_extend_value_internal (msg, &typed_val);
	}
	
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));	
	return required_space;
}

static inline long ei_field_with_name (const char *name, EIF_ENCODED_TYPE enctype) 
{
	long n = ei_count_field_of_type (enctype);
	for (long i = 0; i < n; i++) {
		if (!strcmp (name, ei_field_name_of_type (i, enctype))) {
			return i;
		}
	}
	return -1;
}

static struct eif_dscoop_message_str8_arg* rt_dscoop_message_read_identifier (struct eif_dscoop_message *msg, size_t offset) {
	ssize_t maxlen = msg->length - offset - sizeof (struct eif_dscoop_message_str8_arg) + 1;
	if (maxlen <= 0) {
		return NULL;
	}
	struct eif_dscoop_message_str8_arg* result =
			(struct eif_dscoop_message_str8_arg*) (msg->data.raw + offset);
	if (result->type != A_IDENT) {
		return NULL;
	}
	if (strnlen (result->data, (size_t) maxlen) == (size_t) maxlen) {
		return NULL;
	}
	return result;
}

// Sets a field if possible. May cause garbage collection!!!
static int smart_set_field (EIF_REFERENCE ref, long field, EIF_TYPED_VALUE value)
{
	EIF_NATURAL_32 field_type = ei_field_type_of_type (field, Dftype(ref));
	EIF_TYPE full_field_type;
	full_field_type.annotations = System(Dftype(ref)).cn_attr_flags[field];
	full_field_type.id = field_type & SK_DTYPE;
	
	EIF_TYPE value_type;
	if ((value.type & SK_SIMPLE) == SK_SIMPLE) {
		value_type.id = eif_sk_type_to_dtype (value.type);
		value_type.annotations = ATTACHED_FLAG;
	} else {
		value_type = eif_decoded_type (Dftype (value.item.r));
	}	
	
	if (eif_gen_conf2 (value_type, full_field_type)) {
		if ((value.type & SK_REF) == SK_REF) {
			// The value is a reference
			if (SK_REF == (field_type & SK_REF)) {
				//Both are references, that's easy
				ei_set_reference_field (field, ref, value.item.r);
				return T_OK;
			} else if (SK_EXP == (field_type & SK_EXP)) {
				//We need to set an expanded field.
				size_t len = EIF_Size(field_type & SK_DTYPE);
				memcpy (
						ei_field (field, ref), 
						value.item.r, 
						len);
				return T_OK;
			} else {
				// This might be a boxed value, except that we currently
				// never call this method with a boxed simple value
				// TODO: Maybe we could do a conversion?
				return T_UNKNOWN_ERROR;
			}
		} else {
			if ((field_type & SK_REF) == SK_REF) {
				// A simple case of boxing
				EIF_GET_CONTEXT
				RT_GC_PROTECT (ref);
				ei_set_reference_field (field, ref, eif_box (value));
				RT_GC_WEAN (ref);
				return T_OK;
			}
			switch (value.type) {
				case SK_BOOL:
					switch (field_type) {
						case SK_BOOL:
							ei_set_boolean_field (field, ref, value.item.b);
							return T_OK;
					}
					return T_NOT_CONFORMING;
				case SK_CHAR8:
					switch (field_type) {
						case SK_CHAR8:
							ei_set_char_field (field, ref, value.item.c1);
							return T_OK;
						case SK_CHAR32:
							ei_set_char_32_field (field, ref, value.item.c4);
							return T_OK;
					}
					return T_NOT_CONFORMING;
				case SK_CHAR32:
					switch (field_type) {
						case SK_CHAR32:
							ei_set_char_32_field (field, ref, value.item.c4);
							return T_OK;
					}
					return T_NOT_CONFORMING;
				case SK_FLOAT:
					switch (field_type) {
						case SK_FLOAT:
							ei_set_float_field (field, ref, value.item.r4);
							return T_OK;
						case SK_DOUBLE:
							ei_set_double_field (field, ref, (double) value.item.r4);
							return T_OK;
					}
					return T_NOT_CONFORMING;
				case SK_DOUBLE:
					switch (field_type) {
						case SK_FLOAT:
							ei_set_float_field (field, ref, (float) value.item.r8);
							return T_OK;
						case SK_DOUBLE:
							ei_set_double_field (field, ref, value.item.r8);
							return T_OK;
					}
					return T_NOT_CONFORMING;
				case SK_UINT8:
				case SK_INT8:
					switch (field_type) {
						case SK_UINT8:
						case SK_INT8:
							ei_set_integer_8_field (field, ref, value.item.i1);
							return T_OK;
						case SK_UINT16:
						case SK_INT16:
							ei_set_integer_8_field (field, ref, (EIF_INTEGER_8) value.item.i2);
							return T_OK;
						case SK_UINT32:
						case SK_INT32:
							ei_set_integer_8_field (field, ref, (EIF_INTEGER_8) value.item.i4);
							return T_OK;
						case SK_UINT64:
						case SK_INT64:
							ei_set_integer_8_field (field, ref, (EIF_INTEGER_8) value.item.i8);
							return T_OK;
					}
					return T_NOT_CONFORMING;
				case SK_POINTER:
					switch (field_type) {
						case SK_POINTER:
							ei_set_pointer_field (field, ref, value.item.p);
							return T_OK;
					}
					return T_NOT_CONFORMING;
			}
			// Whatever it is, it is not supported, we put NULL in if the
			// field is
			return T_UNSUPPORTED;
		}
	} else {
		if ((field_type & SK_REF) == SK_REF && 
				full_field_type.annotations & DETACHABLE_FLAG) {
			// Original value does not conform, but the field is detachable,
			// so we set it to NULL
			ei_set_reference_field (field, ref, NULL);
			return T_OK;
		} else {
			// TODO: Maybe we could do a conversion?
			return T_NOT_CONFORMING;
		}
	}
}

static EIF_TYPED_VALUE rt_dscoop_message_read_value (struct eif_dscoop_message* message, size_t offset);

/* Reads the object at pos in the message. */
EIF_REFERENCE rt_dscoop_message_read_object (struct eif_dscoop_message *msg, size_t offset)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	
	struct rt_dscoop_message_object_arg* arg = (struct rt_dscoop_message_object_arg*)
			(msg->data.raw + offset);

	EIF_OBJECT obj = eifcreate (eif_type_id (arg->class_name));

	size_t len = strnlen (arg->class_name, msg->length - offset);
	if (len == msg->length) {
		return NULL;
	}
	
	EIF_TYPE type = eif_type_id2(arg->class_name);
	if (type.id == INVALID_DTYPE) {
		return NULL;
	}
	EIF_ENCODED_TYPE enctype = eif_encoded_type (type);

	offset += sizeof (struct rt_dscoop_message_object_arg) + len;
	for (int i = 0; i < arg->field_count; i++) {
		struct eif_dscoop_message_str8_arg* ident_arg = rt_dscoop_message_read_identifier (msg, offset);
		if (!ident_arg) {
			return NULL;
		}
		offset += sizeof (struct eif_dscoop_message_str8_arg) + strlen (ident_arg->data);
		EIF_TYPED_VALUE arg_value = rt_dscoop_message_read_value (msg, offset);
				
		long field = ei_field_with_name (ident_arg->data, enctype);
		if (field >= 0) {
			int error = smart_set_field (eif_access (obj), field, arg_value);
			if (error) {
				return NULL;
			}
		}
	}
	
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));	
	
	return eif_wean (obj);
	#undef ref
}

size_t rt_dscoop_message_extend_reference (struct eif_dscoop_message *msg, EIF_REFERENCE* ref)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	char* reftype = *ref ? eif_typename (eif_new_type (Dftype (*ref), ATTACHED_FLAG)) + 1
			: "NONE";

	EIF_NATURAL_64 required_space = sizeof (struct eif_dscoop_message_ref_arg) + strlen (reftype);
	enum eif_dscoop_message_arg_type type = A_REF;

	if (eif_dscoop_message_accommodate (msg, required_space)) {
		return 0;
	}

	struct eif_dscoop_message_ref_arg* arg =
			(struct eif_dscoop_message_ref_arg*) (msg->data.raw + msg->length);
	arg->type = (EIF_NATURAL_8) type;

	if (!*ref) {
		arg->oid = 0;
		arg->pid = 0;
		arg->nid = 0;
	} else if (Dtype (*ref) == eif_get_eif_dscoop_proxy_dtype ()) {
		// This is a remote object
		// TODO: Should we send the share request here?
		arg->oid = htobe32 (eif_dscoop_oid_of_proxy (*ref));
		arg->pid = htobe32 (eif_dscoop_pid_of_proxy (*ref));
		arg->nid = htobe64 (eif_dscoop_nid_of_proxy (*ref));
	} else {
		// This is a regular local object
		arg->oid = htobe32 (eif_dscoop_export_object (*ref, eif_dscoop_message_recipient (msg)));
		arg->pid = htobe32 (RTS_PID (*ref));
		arg->nid = htobe64 (eif_dscoop_node_id ());
	}

	strcpy (arg->reftype, reftype);

	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return required_space;
}

EIF_BOOLEAN eif_dscoop_message_invariant (struct eif_dscoop_message* message)
{
	return	message->data.header &&
			message->length == be32toh (message->data.header->length) + sizeof (struct eif_dscoop_message_header) &&
			message->capacity >= message->length;
}

// Resets the message. Exchanges sender and receiver and leaves the id intact

rt_public void eif_dscoop_message_reply (struct eif_dscoop_message* message, enum eif_dscoop_message_subject subject)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	EIF_NATURAL_64 tmp = message->data.header->recipient;
	message->data.header->recipient = message->data.header->sender;
	message->data.header->sender = tmp;
	message->data.header->length = 0;
	message->length = DSCOOP_MESSAGE_HEADER_SIZE;
	eif_dscoop_message_set_subject (message, subject);
	message->arg_count = 0;
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
}

rt_public void eif_dscoop_message_reset (struct eif_dscoop_message * message, enum eif_dscoop_message_subject subject, EIF_NATURAL_64 recipient)
{
	message->length = sizeof (struct eif_dscoop_message_header);
	message->data.header->length = 0;
	message->arg_count = 0;
	eif_dscoop_message_set_id (message, eif_dscoop_message_generate_id ());
	message->data.header->version = 1;
	message->data.header->flags = 0;

	eif_dscoop_message_set_sender (message, eif_dscoop_node_id ());
	eif_dscoop_message_set_recipient (message, recipient);
	eif_dscoop_message_set_subject (message, subject);

	if (message->anchor) {
		eif_wean (message->anchor);
		message->anchor = NULL;
	}
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
}

rt_public void eif_dscoop_message_dispose (struct eif_dscoop_message * message)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	if (message->anchor) {
		eif_wean (message->anchor);
	}
	if (message->data.raw) {
		free (message->data.raw);
	}
}

// Adds the given value argument to the message, returning the byte count of the
// argument. Does not update the index! A result of 0 indicates that some error 
// happened
size_t rt_dscoop_message_extend_value_internal 
		(struct eif_dscoop_message* message, EIF_TYPED_VALUE* arg)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));

	size_t result = 0;

	char* item = NULL;
	switch (arg->type) {
		case SK_CHAR8:
		case SK_UINT8:
		case SK_BOOL:
		case SK_INT8:
			result = 2;
			break;
		case SK_UINT16:
		case SK_INT16:
			result = 3;
			break;
		case SK_CHAR32:
		case SK_UINT32:
		case SK_INT32:
		case SK_REAL32:
			result = 5;
			break;
		case SK_REAL64:
		case SK_UINT64:
		case SK_INT64:
			result = 9;
			break;
		case SK_REF:
			if (arg->item.r && Dtype (arg->item.r) == ESTRING_8_type) {
				item = (char*) ei_ptr_field (4, arg->item.r);
				if (!item) {
					item = "";
				}
				result = sizeof(struct eif_dscoop_message_str8_arg) + strlen (item);
			} else if (EIF_IS_EXPANDED_TYPE (System (Dtype (arg->item.r)))) {
				result = rt_dscoop_message_object_space (&arg->item.r);
			} else {
				result = rt_dscoop_message_reference_space (&arg->item.r);
			}
			break;
		default:
			break;
	}

	if (result > 0) {
		if (eif_dscoop_message_accommodate (message, result)) {
			return 0;
		}
	} else {
		return 0;
	}
	
	switch (arg->type) {
		case SK_CHAR8:
		{
			message->data.raw[message->length] = A_CHAR_8;
			EIF_CHARACTER_8* val = (EIF_CHARACTER_8*)
					(message->data.raw + message->length + 1);
			*val = arg->item.c1;
		}
		break;
		case SK_UINT8:
		{
			message->data.raw[message->length] = A_NAT_8;
			EIF_NATURAL_8* val = (EIF_NATURAL_8*)
					(message->data.raw + message->length + 1);
			*val = arg->item.n1;
		}
		break;
		case SK_BOOL:
		{
			message->data.raw[message->length] = A_BOOL;
			EIF_BOOLEAN* val = (EIF_BOOLEAN*)
					(message->data.raw + message->length + 1);
			*val = arg->item.b;
		}
		break;
		case SK_INT8:
		{
			message->data.raw[message->length] = A_INT_8;
			EIF_INTEGER_8* val = (EIF_INTEGER_8*)
					(message->data.raw + message->length + 1);
			*val = arg->item.i1;
		}
		break;
		case SK_UINT16:
		{
			message->data.raw[message->length] = A_NAT_16;
			EIF_NATURAL_16* val = (EIF_NATURAL_16*)
					(message->data.raw + message->length + 1);
			*val = htobe16 (arg->item.n2);
		}
		break;
		case SK_INT16:
		{
			message->data.raw[message->length] = A_INT_16;
			EIF_INTEGER_16* val = (EIF_INTEGER_16*)
					(message->data.raw + message->length + 1);
			*val = htobe16 (arg->item.i2);
		}
		break;
		case SK_CHAR32:
		{
			message->data.raw[message->length] = A_CHAR_32;
			EIF_CHARACTER_32* val = (EIF_CHARACTER_32*)
					(message->data.raw + message->length + 1);
			*val = htobe32 (arg->item.c4);
		}
		break;
		case SK_REAL32:
		{
			message->data.raw[message->length] = A_REAL_32;
			EIF_NATURAL_32* val = (EIF_NATURAL_32*)
					(message->data.raw + message->length + 1);
			*val = htobe32 (arg->item.n4);
		}
		break;
		case SK_UINT32:
		{
			message->data.raw[message->length] = A_NAT_32;
			EIF_NATURAL_32* val = (EIF_NATURAL_32*)
					(message->data.raw + message->length + 1);
			*val = htobe32 (arg->item.n4);
		}
		break;
		case SK_INT32:
		{
			message->data.raw[message->length] = A_INT_32;
			EIF_INTEGER_32* val = (EIF_INTEGER_32*)
					(message->data.raw + message->length + 1);
			*val = htobe32 (arg->item.i4);
		}
		break;
		case SK_REAL64:
		{
			message->data.raw[message->length] = A_REAL_64;
			EIF_NATURAL_64* val = (EIF_NATURAL_64*)
					(message->data.raw + message->length + 1);
			*val = htobe64 (arg->item.n8);
		}
		break;
		case SK_UINT64:
		{
			message->data.raw[message->length] = A_NAT_64;
			EIF_NATURAL_64* val = (EIF_NATURAL_64*)
					(message->data.raw + message->length + 1);
			*val = htobe64 (arg->item.n8);
		}
		break;
		case SK_INT64:
		{
			message->data.raw[message->length] = A_INT_64;
			EIF_INTEGER_64* val = (EIF_INTEGER_64*)
					(message->data.raw + message->length + 1);
			*val = htobe64 (arg->item.i8);
		}
		break;
		case SK_VOID:
		case SK_EXP:
		case SK_REF:
			if (arg->item.r) {
				if (Dtype (arg->item.r) == ESTRING_8_type) {
					struct eif_dscoop_message_str8_arg* val = (struct eif_dscoop_message_str8_arg*)
							(message->data.raw + message->length);
					val->type = A_STR_8;
					strcpy (val->data, item);
				} else if (SK_EXP == arg->type || EIF_IS_EXPANDED_TYPE (System (Dtype (arg->item.r)))) {
					if (!rt_dscoop_message_extend_object (message, &arg->item.r)) {
						return 0;
					}
				} else {
					if (!rt_dscoop_message_extend_reference (message, &(arg->item.r))) {
						return 0;
					}
				}
			} else {
				if (!rt_dscoop_message_extend_reference (message, &(arg->item.r))) {
					return 0;
				}
			}
			break;
		default:
			break;
	}
	
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return result;
}

// Adds the given typed value to the message and updates the index
rt_public int eif_dscoop_message_add_value_argument (struct eif_dscoop_message* message, EIF_TYPED_VALUE* arg)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));

	size_t space = rt_dscoop_message_extend_value_internal (message, arg);
	if (space) {
		if (eif_dscoop_message_add_index (message, space)) {
			ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
			return T_OK;
		}
	}
	return T_UNKNOWN_ERROR;
}

rt_public EIF_NATURAL_64 eif_dscoop_message_get_natural_argument (struct eif_dscoop_message * message, EIF_NATURAL_8 n)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	REQUIRE ("argument_exists", eif_dscoop_message_get_arg_count (message) > n);
	REQUIRE ("argument_is_natural", eif_dscoop_message_arg_type (message, n) == A_NAT_64);

	size_t offset = message->index[n];
	struct eif_dscoop_message_natural_arg* arg = (struct eif_dscoop_message_natural_arg*)
			(message->data.raw + offset);
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return be64toh (arg->value);
}

char * eif_dscoop_message_get_identifier_argument (struct eif_dscoop_message * message, EIF_NATURAL_8 n)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	REQUIRE ("argument_exists", eif_dscoop_message_get_arg_count (message) > n);
	REQUIRE ("argument_is_ident", eif_dscoop_message_arg_type (message, n) == A_IDENT);

	size_t offset = message->index[n];
	struct eif_dscoop_message_str8_arg* arg = (struct eif_dscoop_message_str8_arg*)
			(message->data.raw + offset);
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return arg->data;
}

EIF_BOOLEAN eif_dscoop_message_initialized (struct eif_dscoop_message *message)
{
	return message->data.raw != 0;
}

struct eif_dscoop_message_request* eif_dscoop_add_message_request (struct eif_dscoop_connection* connection, struct eif_dscoop_message* message)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	eif_pthread_mutex_lock (connection->requests_mutex);
	struct eif_dscoop_message_request *request;
	// We couldn't find a free request slot, so we add one
	request = malloc (sizeof (struct eif_dscoop_message_request));
	request->message = message;
	EIF_NATURAL_32 id = eif_dscoop_message_id (message);
	request->is_active = EIF_TRUE;
	request->is_ready = EIF_FALSE;
	request->is_failed = EIF_FALSE;
	eif_pthread_mutex_create (&request->request_mutex);
	eif_pthread_cond_create (&request->ready);
	eif_dscoop_request_table_extend (&connection->requests, id, request);
	eif_pthread_mutex_unlock (connection->requests_mutex);
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return request;
}

// Send the given message and wait until a reply is received

rt_public EIF_INTEGER_32 eif_dscoop_message_send_receive (struct eif_dscoop_message *message)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));

	struct eif_dscoop_connection* connection = eif_dscoop_get_connection (eif_dscoop_message_recipient (message));
	if (!connection) {
		return 1;
	}
	//	if (!message->id) {
	//		message->id = eif_dscoop_message_generate_id();
	//	}
	struct eif_dscoop_message_request *request = eif_dscoop_add_message_request (connection, message);
	//Send is setting the message id.
	//No additional locking required since the reply cannot arrive before the send
	EIF_INTEGER_32 error = eif_dscoop_message_send (message);
	if (error)
		return error;
	//Waiting for the reply
	EIF_ENTER_C;
	eif_pthread_mutex_lock (request->request_mutex);
	while (!request->is_ready && !request->is_failed) {
		eif_pthread_cond_wait (request->ready, request->request_mutex);
	}
	EIF_BOOLEAN failed = request->is_failed;

	// Resetting the request for later use
	request->is_active = 0;
	eif_pthread_mutex_unlock (request->request_mutex);
	
	EIF_EXIT_C;
	eif_dscoop_release_connection (connection);
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	if (failed) {
		return 1;
	}
	return 0;
}

rt_public const char* eif_dscoop_message_subject_out (enum eif_dscoop_message_subject subject)
{
	switch (subject) {
		case S_OK: return "OK";
		case S_FAIL: return "FAIL";
		case S_HELLO: return "HELLO";
		case S_INDEX: return "INDEX";
		case S_SHARE: return "SHARE";
		case S_RELEASE: return "RELEASE";
		case S_PRELOCK: return "PRELOCK";
		case S_LOCK: return "LOCK";
		case S_UNLOCK: return "UNLOCK";
		case S_AWAIT: return "AWAIT";
		case S_READY: return "READY";
		case S_CALL: return "CALL";
		case S_SCALL: return "SCALL";
		case S_QCALL: return "QCALL";
		default: return "INVALID";
	}
}

rt_public void eif_dscoop_message_print (struct eif_dscoop_message* message)
{
	printf ("%llu -> %llu (%u): %s",
			eif_dscoop_message_sender (message),
			eif_dscoop_message_recipient (message),
			eif_dscoop_message_id (message),
			eif_dscoop_message_subject_out (eif_dscoop_message_subject (message)));

	for (EIF_NATURAL_8 i = 0; i < eif_dscoop_message_argument_count (message); i++) {
		enum eif_dscoop_message_arg_type type = eif_dscoop_message_get_argument_type (message, i);
		size_t offset = message->index[i];
		switch (type) {
			case A_NAT_8:
			{
				EIF_NATURAL_8* val = (EIF_NATURAL_8 *)
						(message->data.raw + offset + 1);
				printf (" %u", *val);
			}
				break;
			case A_NAT_16:
			{
				EIF_NATURAL_16* val = (EIF_NATURAL_16 *)
						(message->data.raw + offset + 1);
				printf (" %u", be16toh (*val));
			}
				break;
			case A_NAT_32:
			{
				EIF_NATURAL_32* val = (EIF_NATURAL_32 *)
						(message->data.raw + offset + 1);
				printf (" %u", be32toh (*val));
			}
				break;
			case A_NIDENT:
			case A_NAT_64:
			{
				EIF_NATURAL_64* val = (EIF_NATURAL_64 *)
						(message->data.raw + offset + 1);
				printf (" %lu", be64toh (*val));
			}
				break;
			case A_INT_8:
			{
				EIF_INTEGER_8* val = (EIF_INTEGER_8 *)
						(message->data.raw + offset + 1);
				printf (" %i", *val);
			}
				break;
			case A_INT_16:
			{
				EIF_INTEGER_16* val = (EIF_INTEGER_16 *)
						(message->data.raw + offset + 1);
				printf (" %i", be16toh (*val));
			}
				break;
			case A_INT_32:
			{
				EIF_INTEGER_32* val = (EIF_INTEGER_32 *)
						(message->data.raw + offset + 1);
				printf (" %i", be32toh (*val));
			}
				break;
			case A_INT_64:
			{
				EIF_INTEGER_64* val = (EIF_INTEGER_64 *)
						(message->data.raw + offset + 1);
				printf (" %li", be64toh (*val));
			}
				break;
			case A_CHAR_8:
			{
				EIF_CHARACTER_8* val = (EIF_CHARACTER_8 *)
						(message->data.raw + offset + 1);
				printf (" %c", *val);
			}
				break;
			case A_CHAR_32:
			{
				EIF_CHARACTER_32* val = (EIF_CHARACTER_32 *)
						(message->data.raw + offset + 1);
				printf (" %u", be32toh (*val));
			}
				break;
			case A_BOOL:
			{
				EIF_BOOLEAN* val = (EIF_BOOLEAN *)
						(message->data.raw + offset + 1);
				if (*val)
					printf (" True");
				else
					printf (" False");
			}
				break;
			case A_REAL_32:
			{
				EIF_NATURAL_32 val =
						be32toh (*(message->data.raw + offset + 1));
				EIF_REAL_32* rval = (void *)&val;
				printf (" %f", *rval);
			}
				break;
			case A_REAL_64:
			{
				EIF_NATURAL_64 val =
						be64toh (*(EIF_NATURAL_64*)(message->data.raw + offset + 1));
				EIF_REAL_64* rval = (void *)&val;
				printf (" %f", *rval);
			}
				break;
			case A_IDENT:
			{
				struct eif_dscoop_message_str8_arg* arg =
						(struct eif_dscoop_message_str8_arg*) (message->data.raw + offset);
				printf (" %s", arg->data);
			}
			break;
			case A_STR_8:
			{
				struct eif_dscoop_message_str8_arg* arg =
						(struct eif_dscoop_message_str8_arg*) (message->data.raw + offset);
				printf (" \"%s\"", arg->data);
			}
			break;
			case A_REF:
			{
				struct eif_dscoop_message_ref_arg* arg =
						(struct eif_dscoop_message_ref_arg*) (message->data.raw + offset);
				if (!strcmp (arg->reftype, "NONE")) {
					printf (" {NONE}Void");
				} else {
					printf (" {%s}<%lu,%u,%u>", arg->reftype, be64toh (arg->nid), be32toh (arg->pid), be32toh (arg->oid));
				}
			}
				break;
			case A_NODE:
			{
				struct eif_dscoop_message_node_arg* arg =
						(struct eif_dscoop_message_node_arg*) (message->data.raw + offset);
				printf (" %lu=%s:%u", be64toh (arg->nid), arg->address, be16toh (arg->port));
			}
				break;
			default:
				printf (" <unknown>");
				break;
		}
	}
	printf ("\n");
}

rt_public EIF_INTEGER_32 eif_dscoop_message_send (struct eif_dscoop_message * message)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));

	struct eif_dscoop_connection* connection = eif_dscoop_get_connection (eif_dscoop_message_recipient (message));
	if (!connection) {
		return 1;
	}

	while (!connection->socket) {
		connection = connection->relay;
	}

	if (eif_dscoop_print_debug_messages) {
		printf ("Sent request: "); eif_dscoop_message_print (message);
	}

	eif_pthread_mutex_lock (connection->send_mutex);

	if (-1 == send (connection->socket, message->data.raw, message->length, MSG_NOSIGNAL)) {
		return errno;
	}
	eif_pthread_mutex_unlock (connection->send_mutex);
	eif_dscoop_release_connection (connection);
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return T_OK;
}

rt_public EIF_NATURAL_8 eif_dscoop_message_get_arg_count (struct eif_dscoop_message* message)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return message->arg_count;
}

rt_public EIF_NATURAL_32 eif_dscoop_message_get_argument_type (struct eif_dscoop_message* message, EIF_NATURAL_8 n)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	REQUIRE ("argument_exists", eif_dscoop_message_get_arg_count (message) > n);
	size_t offset = message->index[n];
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return message->data.raw[offset];
}

rt_public EIF_NATURAL_32 eif_dscoop_message_is_argument_value (struct eif_dscoop_message* message, EIF_NATURAL_8 n)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	REQUIRE ("argument_exists", eif_dscoop_message_get_arg_count (message) > n);
	size_t offset = message->index[n];
	enum eif_dscoop_message_arg_type t = message->data.raw[offset];
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return t >= A_NAT_8 && t <= A_AGENT;
}

rt_public EIF_NATURAL_32 eif_dscoop_message_is_ref_argument (struct eif_dscoop_message* message, EIF_NATURAL_8 n)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	REQUIRE ("argument_exists", eif_dscoop_message_get_arg_count (message) > n);
	REQUIRE ("argument_is_value", eif_dscoop_message_is_argument_value (message));
	size_t offset = message->index[n];
	enum eif_dscoop_message_arg_type t = message->data.raw[offset];
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return t == A_REF || t == A_STR_32 || t == A_STR_8 || t == A_OBJ || t == A_CUSTOM || t == A_AGENT;
}

rt_public EIF_NATURAL_64 eif_dscoop_message_get_node_argument (struct eif_dscoop_message* message, EIF_NATURAL_8 n, char** address, EIF_NATURAL_16* port) {
	size_t offset = message->index[n];
	struct eif_dscoop_message_node_arg* arg =
			(struct eif_dscoop_message_node_arg*) (message->data.raw + offset);
	if (arg->type != A_NODE) {
		return 0;
	}
	int len = strlen(arg->address);
	if (len == 0) {
		return 0;
	}
	(*address) = malloc(len + 1);
	strcpy (*address, arg->address);
	(*port) = be16toh (arg->port);
	return be64toh (arg->nid);
}

// Retrieves the n-th argument. The argument has to be a typed value.
static EIF_TYPED_VALUE rt_dscoop_message_read_value (struct eif_dscoop_message* message, size_t offset)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	EIF_GET_CONTEXT
	EIF_TYPED_VALUE result;
	result.type = SK_INVALID;

	enum eif_dscoop_message_arg_type type = message->data.raw[offset];
	switch (type) {
		case A_NAT_8:
		{
			EIF_NATURAL_8* val = (EIF_NATURAL_8 *)
					(message->data.raw + offset + 1);
			result.type = SK_UINT8;
			result.item.n1 = *val;
		}
		break;
		case A_NAT_16:
		{
			EIF_NATURAL_16* val = (EIF_NATURAL_16 *)
					(message->data.raw + offset + 1);
			result.type = SK_UINT16;
			result.item.n2 = be16toh (*val);
		}
		break;
		case A_NAT_32:
		{
			EIF_NATURAL_32* val = (EIF_NATURAL_32 *)
					(message->data.raw + offset + 1);
			result.type = SK_UINT32;
			result.item.n4 = be32toh (*val);
		}
		break;
		case A_NAT_64:
		{
			EIF_NATURAL_64* val = (EIF_NATURAL_64 *)
					(message->data.raw + offset + 1);
			result.type = SK_UINT64;
			result.item.n8 = be64toh (*val);
		}
		break;
		case A_INT_8:
		{
			EIF_INTEGER_8* val = (EIF_INTEGER_8 *)
					(message->data.raw + offset + 1);
			result.type = SK_UINT8;
			result.item.i1 = *val;
		}
		break;
		case A_INT_16:
		{
			EIF_INTEGER_16* val = (EIF_INTEGER_16 *)
					(message->data.raw + offset + 1);
			result.type = SK_UINT16;
			result.item.i2 = be16toh (*val);
		}
		break;
		case A_INT_32:
		{
			EIF_INTEGER_32* val = (EIF_INTEGER_32 *)
					(message->data.raw + offset + 1);
			result.type = SK_UINT32;
			result.item.i4 = be32toh (*val);
		}
		break;
		case A_INT_64:
		{
			EIF_INTEGER_64* val = (EIF_INTEGER_64 *)
					(message->data.raw + offset + 1);
			result.type = SK_UINT64;
			result.item.i8 = be64toh (*val);
		}
		break;
		case A_CHAR_8:
		{
			EIF_CHARACTER_8* val = (EIF_CHARACTER_8 *)
					(message->data.raw + offset + 1);
			result.type = SK_CHAR8;
			result.item.c1 = *val;
		}
		break;
		case A_CHAR_32:
		{
			EIF_CHARACTER_32* val = (EIF_CHARACTER_32 *)
					(message->data.raw + offset + 1);
			result.type = SK_CHAR32;
			result.item.c4 = be32toh (*val);
		}
		break;
		case A_BOOL:
		{
			EIF_BOOLEAN* val = (EIF_BOOLEAN *)
					(message->data.raw + offset + 1);
			result.type = SK_BOOL;
			result.item.b = *val;
		}
		break;
		case A_REAL_32:
		{
			EIF_NATURAL_32* val = (EIF_NATURAL_32 *)
					(message->data.raw + offset + 1);
			result.type = SK_REAL32;
			result.item.n4 = be32toh (*val);
		}
		break;
		case A_REAL_64:
		{
			EIF_NATURAL_64* val = (EIF_NATURAL_64 *)
					(message->data.raw + offset + 1);
			result.type = SK_REAL64;
			result.item.n8 = be64toh (*val);
		}
		break;
		case A_STR_8:
		{
			EIF_TYPE_ID t = eif_type_id ("ESTRING_8");
			EIF_OBJECT str = eif_create (t);
			RTS_PID (eif_access (str)) = eif_globals->scoop_region_id;
			struct eif_dscoop_message_str8_arg* arg =
					(struct eif_dscoop_message_str8_arg*) (message->data.raw + offset);
			EIF_PROCEDURE p = (EIF_PROCEDURE) eifref ("make_from_c", t);
			p (eif_access (str), arg->data);
			result.item.r = eif_wean (str);
			result.type = SK_REF;
		}
		break;
		case A_REF:
		{
			struct eif_dscoop_message_ref_arg* arg =
					(struct eif_dscoop_message_ref_arg*) (message->data.raw + offset);
			if (!strcmp (arg->reftype, "NONE")) {
				result.item.r = NULL;
				result.type = SK_REF;
			} else {
				result.item.r = eif_dscoop_get_remote_object (be64toh (arg->nid), be32toh (arg->pid), be32toh (arg->oid), arg->reftype, eif_dscoop_message_sender (message));
				result.type = SK_REF;
			}
		}
		break;
		case A_OBJ:
		{
			result.item.r = rt_dscoop_message_read_object (message, offset);
			if (result.item.r) {
				result.type = SK_REF;
			} else {
				result.type = SK_VOID;
			}
		}
		default:
			result.item.r = NULL;
			result.type = SK_VOID;
	}
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return result;
}

// Retrieves the n-th argument. The argument has to be a typed value.
rt_public EIF_TYPED_VALUE eif_dscoop_message_get_value_argument (struct eif_dscoop_message* message, EIF_NATURAL_8 n)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	REQUIRE ("argument_exists", eif_dscoop_message_get_arg_count (message) > n);
	REQUIRE ("argument_is_value", eif_dscoop_message_is_argument_value (message, n));
	return rt_dscoop_message_read_value(message, message->index[n]);
}

rt_public EIF_BOOLEAN eif_dscoop_message_ok (struct eif_dscoop_message * message)
{
	return message->data.header->subject == S_OK;
}

rt_private EIF_INTEGER_32 receive_exact_amount (int fd, void* buf, EIF_INTEGER_32 len)
{
	int pos = 0;
	EIF_ENTER_C;
	while (pos < len) {
		int bytes = recv (fd, ((char *) buf) + pos, len - pos, MSG_NOSIGNAL);
		if (bytes > 0) {
			pos += bytes;
		} else {
			return pos;
		}
	}
	EIF_EXIT_C;
	return pos;
}

int rt_dscoop_index_data (EIF_NATURAL_8 data[], size_t data_offset, size_t data_size, EIF_NATURAL_64* index, size_t index_size)
{
	size_t arg_count = 0;
	size_t skip = 0;
	for (size_t pos = data_offset; pos < data_size && arg_count <= index_size; ) {
		if (skip > 0) {
			skip--;
		} else {
			index[arg_count++] = pos;
		}
		enum eif_dscoop_message_arg_type t = data[pos];
		switch (t) {
			case A_INT_8:
			case A_NAT_8:
			case A_BOOL:
			case A_CHAR_8:
				pos += 1 + 1;
				break;
			case A_INT_16:
			case A_NAT_16:
			case A_REAL_16:
				pos += 1 + 2;
				break;
			case A_INT_32:
			case A_NAT_32:
			case A_REAL_32:
			case A_CHAR_32:
				pos += 1 + 4;
				break;
			case A_NIDENT:
			case A_INT_64:
			case A_NAT_64:
			case A_REAL_64:
				pos += 1 + 8;
				break;
			case A_STR_32:
			{
				struct eif_dscoop_message_str32_arg* arg =
						(struct eif_dscoop_message_str32_arg*) (data + pos);
				pos += sizeof (struct eif_dscoop_message_str32_arg) + 4 * str32len(arg->data);
			}
			break;
			case A_IDENT:
			case A_STR_8:
			{
				struct eif_dscoop_message_str8_arg* arg =
						(struct eif_dscoop_message_str8_arg*) (data + pos);
				pos += sizeof (struct eif_dscoop_message_str8_arg) + strlen (arg->data);
			}
			break;
			case A_REF:
			{
				struct eif_dscoop_message_ref_arg* arg =
						(struct eif_dscoop_message_ref_arg*) (data + pos);
				pos += sizeof (struct eif_dscoop_message_ref_arg) + strlen (arg->reftype);
			}
			break;
			case A_NODE:
			{
				struct eif_dscoop_message_node_arg* arg =
						(struct eif_dscoop_message_node_arg*) (data + pos);
				pos += sizeof (struct eif_dscoop_message_node_arg) + strlen(arg->address);
			}
			break;
			case A_OBJ:
			{
				struct rt_dscoop_message_object_arg* arg =
						(struct rt_dscoop_message_object_arg*) (data + pos);
				pos += sizeof (struct eif_dscoop_message_node_arg) + strlen(arg->class_name);
				skip = arg->field_count;
			}
			break;
			case A_AGENT:
			case A_CUSTOM:
			default:
				return -1;
		}
	}
	return arg_count;
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
}

EIF_BOOLEAN rt_dscoop_message_index (struct eif_dscoop_message* message)
{
	REQUIRE ("eif_dscoop_message_initialized", eif_dscoop_message_initialized (message));
	ssize_t result = rt_dscoop_index_data (message->data.raw, DSCOOP_MESSAGE_HEADER_SIZE, message->length, message->index, DSCOOP_MAX_ARGUMENTS);
	message->arg_count = result > 0 ? result : 0;
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return result >= 0;
}

EIF_BOOLEAN eif_dscoop_message_receive_request (struct eif_dscoop_connection* connection, struct eif_dscoop_message* result)
{
	// This function actually does two things: If the incoming message is a
	// response to a request, it forwards the message to the recipient. This is
	// done repeatedly until a message is received that has is not anticipated.
	// It will then fill the message in the argument accordingly and return.
	// It will return a non-zero value if an error occurred and the message
	// was not written. Unlike send, this feature takes a connection, because
	// it handles replies and relays.

	int fd = connection->socket;
	//If a sender waits for a response, this variable will contain the request.
	struct eif_dscoop_message_request *request = NULL;
	struct eif_dscoop_message* message = NULL;
	EIF_BOOLEAN is_reply = EIF_FALSE;
	
	do {
		request = NULL;
		struct eif_dscoop_message_header header;
		if (receive_exact_amount (fd, &header, DSCOOP_MESSAGE_HEADER_SIZE) != DSCOOP_MESSAGE_HEADER_SIZE) {
			//Connection closed
			return EIF_FALSE;
		}

		EIF_NATURAL_32 body_length = be32toh (header.length);
		EIF_NATURAL_64 recipient = be64toh (header.recipient);
		enum eif_dscoop_message_subject subject = header.subject;
		EIF_NATURAL_32 id = be32toh (header.id);
		is_reply = subject == S_OK || subject == S_FAIL;

		if (recipient != eif_dscoop_node_id ()) {
			// Relaying is not supported (yet), we ignore this message
			char* tmp = malloc (body_length);
			receive_exact_amount (fd, tmp, body_length);
			free (tmp);
			continue;
		} else if (is_reply) {
			// It is a reply, so we need to check for a waiting request
			// We either get the waiting message or create a new one.
			eif_pthread_mutex_lock (connection->requests_mutex);
			request = eif_dscoop_request_table_item (&(connection->requests), id);
			if (request) {
				// We need to lock if we want to access the message, since
				// the request could turn invalid while we try to read the id
				eif_pthread_mutex_lock (request->request_mutex);
				// Checking whether the request is still the right one
				message = request->message;
				eif_pthread_mutex_unlock (request->request_mutex);
				eif_dscoop_request_table_remove (&(connection->requests), id, NULL);
			}
			eif_pthread_mutex_unlock (connection->requests_mutex);
			if (!request) {
				// A stray reply can be ignored, but needs to be read
				char* tmp = malloc (body_length);
				receive_exact_amount (fd, tmp, body_length);
				free (tmp);
				continue;
			}
		} else {
			message = result;
		}

		eif_dscoop_message_accommodate (message, DSCOOP_MESSAGE_HEADER_SIZE + body_length);
		// We simply overwrite the header of the message
		memcpy (message->data.raw, &header, DSCOOP_MESSAGE_HEADER_SIZE);
		if ((int) body_length == receive_exact_amount (fd, message->data.raw + DSCOOP_MESSAGE_HEADER_SIZE, body_length)) {
			message->length = body_length + DSCOOP_MESSAGE_HEADER_SIZE;
		}

		if (!rt_dscoop_message_index (message)) {
			// Indexing failed, so we ignore the message
			// TODO: Maybe we should inform waiting requests?
			// OTOH, waiting requests should time out anyway ...
			continue;
		}

		if (eif_dscoop_print_debug_messages) {
			printf ("Received request: "); eif_dscoop_message_print (message);
		}
		if (is_reply) {
			CHECK ("request_not_null", request);
			request->is_ready = EIF_TRUE;
			// Release the request and signal
			eif_pthread_cond_signal (request->ready);
			eif_pthread_mutex_unlock (request->request_mutex);
		} else {
			// We do not need to do anything here in the case of requests
		}
	} while (is_reply);
	return EIF_TRUE;
}

rt_public EIF_NATURAL_8 eif_dscoop_message_argument_count (struct eif_dscoop_message* msg)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return msg->arg_count;
}

rt_public EIF_NATURAL_64 eif_dscoop_message_sender (struct eif_dscoop_message* msg)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return be64toh (msg->data.header->sender);
}

rt_public EIF_NATURAL_64 eif_dscoop_message_recipient (struct eif_dscoop_message* msg)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return be64toh (msg->data.header->recipient);
}

rt_public enum eif_dscoop_message_subject eif_dscoop_message_subject (struct eif_dscoop_message* msg)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return msg->data.header->subject;
}

rt_public EIF_NATURAL_32 eif_dscoop_message_id (struct eif_dscoop_message* msg)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return be32toh (msg->data.header->id);
}

rt_public void eif_dscoop_message_set_sender (struct eif_dscoop_message* msg, EIF_NATURAL_64 sender)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	msg->data.header->sender = htobe64 (sender);
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	ENSURE ("data_set", eif_dscoop_message_sender (message) == sender);
}

rt_public void eif_dscoop_message_set_recipient (struct eif_dscoop_message* msg, EIF_NATURAL_64 recipient)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	msg->data.header->recipient = htobe64 (recipient);
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	ENSURE ("data_set", eif_dscoop_message_recipient (message) == recipient);
}

rt_public void eif_dscoop_message_set_subject (struct eif_dscoop_message* msg, enum eif_dscoop_message_subject subject)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	msg->data.header->subject = (EIF_NATURAL_8) subject;
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	ENSURE ("data_set", eif_dscoop_message_subject (message) == subject);
}

rt_public void eif_dscoop_message_set_id (struct eif_dscoop_message* msg, EIF_NATURAL_32 id)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	msg->data.header->id = htobe32 (id);
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	ENSURE ("data_set", eif_dscoop_message_subject (message) == subject);
}