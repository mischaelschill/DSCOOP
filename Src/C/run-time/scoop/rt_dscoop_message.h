/* 
 * File:   rt_dscoop_message.h
 * Author: Mischael Schill <mischael.schill@inf.ethz.ch>
 *
 * Created on May 4, 2016, 2:27 PM
 */

#ifndef RT_DSCOOP_MESSAGE_H
#define	RT_DSCOOP_MESSAGE_H

#ifdef	__cplusplus
extern "C" {
#endif

#define DSCOOP_MAX_ARGUMENTS 32

enum eif_dscoop_message_subject {
	S_INVALID = 0,
	S_OK = 1,
	S_FAIL = 2,
	S_HELLO = 11,
	S_INDEX = 21,
	S_SHARE = 51,
	S_RELEASE = 52,
	S_PRELOCK = 101,
	S_LOCK = 102,
	S_UNLOCK = 103,
	S_AWAIT = 104,
	S_READY = 105,
	S_CALL = 111,
	S_QCALL = 112,
	S_SCALL = 113
};

enum eif_dscoop_message_arg_type
{
	A_INVALID = 0, // Not a valid type
	A_IDENT = 1, // Textual identifier (no whitespace allowed)
	A_NIDENT = 2, // Natural identifier
	// Typed values
	// Naturals
	A_NAT_8 = 101,
	A_NAT_16 = 102,
	A_NAT_32 = 103,
	A_NAT_64 = 104,
	// Integers
	A_INT_8 = 111,
	A_INT_16 = 112,
	A_INT_32 = 113,
	A_INT_64 = 114,
	// Floats
	A_REAL_16 = 121,
	A_REAL_32 = 122,
	A_REAL_64 = 123,
	//BOOLEAN
	A_BOOL = 131,
	A_CHAR_8 = 132,
	A_CHAR_32 = 134,
	// Strings (as value)
	A_STR_8 = 141,
	A_STR_32 = 143,
	// References
	A_REF = 151,
	// Other Values (serialized objects)
	A_OBJ = 152,
	// Custom serialized object
	A_CUSTOM = 153,
	// Agents
	A_AGENT = 155,
	A_OPEN_ARG = 156,
	A_NODE = 160
};

struct eif_dscoop_message_header;

struct eif_dscoop_message {
	union {
		struct eif_dscoop_message_header* header;
		EIF_NATURAL_8* raw;
	} data;
	EIF_NATURAL_64 length; // Total length of data, should be data->length + sizeof (eif_dscoop_message_header)
	EIF_NATURAL_64 capacity;
	EIF_NATURAL_64 index[DSCOOP_MAX_ARGUMENTS];
	EIF_NATURAL_8 arg_count;
	EIF_OBJECT anchor;
};

struct eif_dscoop_connection;
struct rt_processor;

void eif_dscoop_message_reply (struct eif_dscoop_message * message, enum eif_dscoop_message_subject subject);

void eif_dscoop_message_reset (struct eif_dscoop_message * message, enum eif_dscoop_message_subject subject, EIF_NATURAL_64 receiver);

void eif_dscoop_message_init (struct eif_dscoop_message * message, enum eif_dscoop_message_subject subject, EIF_NATURAL_64 receiver);

void eif_dscoop_message_dispose (struct eif_dscoop_message * message);

int eif_dscoop_message_add_value_argument (struct eif_dscoop_message * message, EIF_TYPED_VALUE* arg);

int eif_dscoop_message_add_natural_argument (struct eif_dscoop_message * message, EIF_NATURAL_64 arg);

int eif_dscoop_message_add_identifier_argument (struct eif_dscoop_message * message, const char * identifier);

ssize_t eif_dscoop_message_parse (struct eif_dscoop_message * message, const char * content);

// If message->id is 0, a fresh message->id will be generated
EIF_INTEGER_32 eif_dscoop_message_send (struct eif_dscoop_message * message);

// Send the given message and then wait for a reply
EIF_INTEGER_32 eif_dscoop_message_send_receive (struct eif_dscoop_message *message);

EIF_TYPED_VALUE eif_dscoop_message_get_value_argument (struct eif_dscoop_message * message, EIF_NATURAL_8 n);

EIF_NATURAL_64 eif_dscoop_message_get_natural_argument (struct eif_dscoop_message * message, EIF_NATURAL_8 n);

char * eif_dscoop_message_get_identifier_argument (struct eif_dscoop_message * message, EIF_NATURAL_8 n);

EIF_NATURAL_64 eif_dscoop_message_get_node_argument (struct eif_dscoop_message* message, EIF_NATURAL_8 n, char** address, EIF_NATURAL_16* port);

EIF_BOOLEAN eif_dscoop_message_ok (struct eif_dscoop_message * message);

EIF_BOOLEAN rt_dscoop_message_handle_one (struct rt_processor* self, struct eif_dscoop_connection *connection);

EIF_NATURAL_64 eif_dscoop_message_sender (struct eif_dscoop_message* msg);

EIF_NATURAL_64 eif_dscoop_message_recipient (struct eif_dscoop_message* msg);

enum eif_dscoop_message_subject eif_dscoop_message_subject (struct eif_dscoop_message* msg);

EIF_NATURAL_32 eif_dscoop_message_id (struct eif_dscoop_message* msg);

EIF_NATURAL_8 eif_dscoop_message_argument_count (struct eif_dscoop_message* msg);

EIF_NATURAL_32 eif_dscoop_message_get_argument_type (struct eif_dscoop_message* message, EIF_NATURAL_8 n);

void eif_dscoop_message_set_sender (struct eif_dscoop_message* msg, EIF_NATURAL_64 sender);

void eif_dscoop_message_set_recipient (struct eif_dscoop_message* msg, EIF_NATURAL_64 recipient);

void eif_dscoop_message_set_subject (struct eif_dscoop_message* msg, enum eif_dscoop_message_subject subject);

void eif_dscoop_message_set_id (struct eif_dscoop_message* msg, EIF_NATURAL_32 id);

int eif_dscoop_message_add_node_argument (struct eif_dscoop_message *msg, EIF_NATURAL_64 nid, char *address, EIF_NATURAL_16 port);

EIF_NATURAL_32 eif_dscoop_message_is_argument_value (struct eif_dscoop_message* message, EIF_NATURAL_8 n);

EIF_BOOLEAN eif_dscoop_message_receive_request (struct eif_dscoop_connection* connection, struct eif_dscoop_message* result);

#ifdef	__cplusplus
}
#endif

#endif	/* RT_DSCOOP_MESSAGE_H */

