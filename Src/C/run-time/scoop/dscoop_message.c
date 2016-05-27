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

int eif_dscoop_message_add_identifier_argument (struct eif_dscoop_message *msg, char * ident)
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

int eif_dscoop_message_add_ref_arg (struct eif_dscoop_message *msg, EIF_REFERENCE* ref)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	char* reftype = *ref ? eif_typename (eif_new_type (Dftype (*ref), ATTACHED_FLAG)) + 1
			: "NONE";

	EIF_NATURAL_64 required_space = sizeof (struct eif_dscoop_message_ref_arg) + strlen (reftype);
	enum eif_dscoop_message_arg_type type = A_REF;

	int error = eif_dscoop_message_accommodate (msg, required_space);
	if (error) {
		return error;
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

	//Update the index and length
	eif_dscoop_message_add_index (msg, required_space);
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return T_OK;
}

char* encode_string_8 (char * input)
{
	int i, j, count, len;

	count = 3;
	len = strlen (input);
	for (i = 0; i < len; i++) {
		char val = input[i];
		switch (val) {
			case '\n':
			case '\t':
			case '\r':
			case 0:
			case '%':
			case '"':
				count += 2;
				break;
			default:
				if (val >= ' ' && val <= '~')
					count++;
				else
					count += strlen ("%/256/");
		}
	}

	char * ret = malloc (count);
	j = 0;
	CHECK ("Correct count calculation", j < count);
	ret[j++] = '"';
	for (i = 0; i < len; i++) {
		char val = input[i];
		switch (val) {
			case '\n':
				CHECK ("Correct count calculation", j < count);
				ret[j++] = '%';
				CHECK ("Correct count calculation", j < count);
				ret[j++] = 'N';
				break;
			case '\t':
				CHECK ("Correct count calculation", j < count);
				ret[j++] = '%';
				CHECK ("Correct count calculation", j < count);
				ret[j++] = 'T';
				break;
			case '\r':
				CHECK ("Correct count calculation", j < count);
				ret[j++] = '%';
				CHECK ("Correct count calculation", j < count);
				ret[j++] = 'R';
				break;
			case 0:
				CHECK ("Correct count calculation", j < count);
				ret[j++] = '%';
				CHECK ("Correct count calculation", j < count);
				ret[j++] = 'U';
				break;
			case '%':
				CHECK ("Correct count calculation", j < count);
				ret[j++] = '%';
				CHECK ("Correct count calculation", j < count);
				ret[j++] = '%';
				break;
			case '"':
				CHECK ("Correct count calculation", j < count);
				ret[j++] = '%';
				CHECK ("Correct count calculation", j < count);
				ret[j++] = '"';
				break;
			default:
				if (val >= ' ' && val <= '~') {
					CHECK ("Correct count calculation", j < count);
					ret[j++] = val;
				} else {
					CHECK ("Correct count calculation", j < count);
					ret[j++] = '%';
					CHECK ("Correct count calculation", j < count);
					ret[j++] = '/';
					char code[4];
					snprintf (code, 4, "%hhu", val);
					for (int k = 0; k < 4 && code[k]; k++) {
						CHECK ("Correct count calculation", j < count);
						ret[j++] = code[k];
					}
					CHECK ("Correct count calculation", j < count);
					ret[j++] = '/';
				}
		}
	}
	CHECK ("Correct count calculation", j < count);
	ret[j++] = '"';
	CHECK ("Correct count calculation", j < count);
	ret[j++] = 0;
	CHECK ("Correct count calculation", j = count);
	return ret;
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

rt_public int eif_dscoop_message_add_value_argument (struct eif_dscoop_message* message, EIF_TYPED_VALUE* arg, EIF_NATURAL_64 client_nid)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));

	int error = T_OK;

	char* item = NULL;
	switch (arg->type) {
		case SK_CHAR8:
		case SK_UINT8:
		case SK_BOOL:
		case SK_INT8:
			error = eif_dscoop_message_accommodate (message, 2);
			break;
		case SK_UINT16:
		case SK_INT16:
			error = eif_dscoop_message_accommodate (message, 3);
			break;
		case SK_CHAR32:
		case SK_UINT32:
		case SK_INT32:
		case SK_REAL32:
			error = eif_dscoop_message_accommodate (message, 5);
			break;
		case SK_REAL64:
		case SK_UINT64:
		case SK_INT64:
			error = eif_dscoop_message_accommodate (message, 9);
			break;
		case SK_REF:
			if (arg->item.r && Dtype (arg->item.r) == ESTRING_8_type) {
				item = (char*) ei_ptr_field (4, arg->item.r);
				if (!item) {
					item = "";
				}
				error = eif_dscoop_message_accommodate (message, sizeof(struct eif_dscoop_message_str8_arg) + strlen (item));
			}
			break;
		default:
			break;
	}
	if (error) return error;
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
		case SK_REF:
			if (arg->item.r && Dtype (arg->item.r) == ESTRING_8_type) {
				struct eif_dscoop_message_str8_arg* val = (struct eif_dscoop_message_str8_arg*)
						(message->data.raw + message->length);
				val->type = A_STR_8;
				strcpy (val->data, item);
			} else {
				error = eif_dscoop_message_add_ref_arg (message, &(arg->item.r));
			}
			break;
		default:
			break;
	}

	if (error) {
		return error;
	}

	switch (arg->type) {
		case SK_CHAR8:
		case SK_UINT8:
		case SK_BOOL:
		case SK_INT8:
			error = eif_dscoop_message_add_index (message, 2);
			break;
		case SK_UINT16:
		case SK_INT16:
			error = eif_dscoop_message_add_index (message, 3);
			break;
		case SK_CHAR32:
		case SK_UINT32:
		case SK_INT32:
		case SK_REAL32:
			error = eif_dscoop_message_add_index (message, 5);
			break;
		case SK_REAL64:
		case SK_UINT64:
		case SK_INT64:
			error = eif_dscoop_message_add_index (message, 9);
			break;
		case SK_REF:
			if (arg->item.r && Dtype (arg->item.r) == ESTRING_8_type) {
				error = eif_dscoop_message_add_index (message, sizeof (struct eif_dscoop_message_str8_arg) + strlen (item));
			}
			break;
		default:
			break;
	}

	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return error;

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
	return t == A_REF || t == A_STR_32 || t == A_STR_8 || t == A_VAL || t == A_CUSTOM || t == A_AGENT;
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
rt_public EIF_TYPED_VALUE eif_dscoop_message_get_value_argument (struct eif_dscoop_message* message, EIF_NATURAL_8 n)
{
	REQUIRE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	REQUIRE ("argument_exists", eif_dscoop_message_get_arg_count (message) > n);
	REQUIRE ("argument_is_value", eif_dscoop_message_is_argument_value (message));
	EIF_GET_CONTEXT
	EIF_TYPED_VALUE result;

	size_t offset = message->index[n];
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
		default:
			result.item.r = NULL;
			result.type = SK_VOID;
	}
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
	return result;
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

rt_public EIF_INTEGER_32 eif_dscoop_message_index (struct eif_dscoop_message* message)
{
	REQUIRE ("eif_dscoop_message_initialized", eif_dscoop_message_initialized (message));
	message->arg_count = 0;
	int pos = DSCOOP_MESSAGE_HEADER_SIZE;
	while (pos < (int) message->length) {
		message->index[message->arg_count++] = pos;
		enum eif_dscoop_message_arg_type t = message->data.raw[pos];
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
						(struct eif_dscoop_message_str32_arg*) (message->data.raw + pos);
				pos += sizeof (struct eif_dscoop_message_str32_arg) + 4 * str32len(arg->data);
			}
			break;
			case A_IDENT:
			case A_STR_8:
			{
				struct eif_dscoop_message_str8_arg* arg =
						(struct eif_dscoop_message_str8_arg*) (message->data.raw + pos);
				pos += sizeof (struct eif_dscoop_message_str8_arg) + strlen (arg->data);
			}
			break;
			case A_REF:
			{
				struct eif_dscoop_message_ref_arg* arg =
						(struct eif_dscoop_message_ref_arg*) (message->data.raw + pos);
				pos += sizeof (struct eif_dscoop_message_ref_arg) + strlen (arg->reftype);
			}
			break;
			case A_NODE:
			{
				struct eif_dscoop_message_node_arg* arg =
						(struct eif_dscoop_message_node_arg*) (message->data.raw + pos);
				pos += sizeof (struct eif_dscoop_message_node_arg) + strlen(arg->address);
			}
			break;
			case A_VAL:
			case A_AGENT:
			case A_CUSTOM:
			default:
				return T_UNKNOWN_ERROR;
		}
	}
	return T_OK;
	ENSURE ("eif_dscoop_message_invariant", eif_dscoop_message_invariant (message));
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

		if (eif_dscoop_message_index (message)) {
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