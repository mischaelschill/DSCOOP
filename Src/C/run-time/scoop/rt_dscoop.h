/* 
 * File:   rt_sei.h
 * Author: Mischael Schill <mischael.schill@inf.ethz.ch>
 *
 * Created on July 17, 2015, 4:38 PM
 */

#ifndef RT_DSCOOP_H
#define	RT_DSCOOP_H

#include "../include/rt_vector.h"
#include "../eif_threads.h"
#include "../eif_dscoop.h"
#include "../eif_scoop.h"
#include "rt_garcol.h"
#define DSCOOP_BUF_SIZE 32
#define DSCOOP_INIT_SIZE 32
#define DSCOOP_MAX_ARGUMENTS 32

#ifdef	__cplusplus
extern "C" {
#endif

typedef EIF_NATURAL_64 EIF_DSCOOP_NID;
typedef EIF_NATURAL_32 EIF_DSCOOP_PID;
typedef EIF_NATURAL_32 EIF_DSCOOP_OID;

//A DSCOOP message, the detailed definition is hidden
struct eif_dscoop_message; 

// Compensations
struct eif_dscoop_compensation {
	EIF_NATURAL_64 serial_no;
	EIF_OBJECT agent;
};

RT_DECLARE_VECTOR (eif_dscoop_compensation_list, struct eif_dscoop_compensation)

struct eif_dscoop_message_request {
	struct eif_dscoop_message *message;
	EIF_MUTEX_TYPE *request_mutex;
	EIF_COND_TYPE *ready;
	EIF_BOOLEAN is_active;
	EIF_BOOLEAN is_ready;
	EIF_BOOLEAN is_failed;
};

#define RT_CHT_NAMESPACE(suffix) eif_dscoop_request_table##suffix
#define RT_CHT_KEY_TYPE EIF_NATURAL_32
#define RT_CHT_VALUE_TYPE struct eif_dscoop_message_request*
#include "../include/rt_cuckoo_hash.h"
#undef RT_CHT_NAMESPACE
#undef RT_CHT_KEY_TYPE
#undef RT_CHT_VALUE_TYPE

// The data structure containing all information about a connection
struct eif_dscoop_connection {
	EIF_REFERENCE index_object_ref;
	EIF_MUTEX_TYPE *send_mutex;
	EIF_MUTEX_TYPE *requests_mutex;
	struct eif_dscoop_request_table requests;
	struct {
		struct eif_dscoop_message *message;
		EIF_MUTEX_TYPE *lock;
		EIF_COND_TYPE *free, *ready;
	} default_handler;
	int socket; // If socket is 0, there is no direct connection
	struct {
		char data[DSCOOP_BUF_SIZE];
		int offset, len;
	} buffer;
	struct eif_dscoop_connection* relay;
	EIF_DSCOOP_NID remote_nid;
	char *node_address;
	int reference_count;
	EIF_NATURAL_16 node_port;
};

// The table with all the connections
#define RT_CHT_NAMESPACE(suffix) eif_dscoop_connection_table##suffix
#define RT_CHT_KEY_TYPE EIF_DSCOOP_NID
#define RT_CHT_VALUE_TYPE struct eif_dscoop_connection*
#include "../include/rt_cuckoo_hash.h"
#undef RT_CHT_NAMESPACE
#undef RT_CHT_KEY_TYPE
#undef RT_CHT_VALUE_TYPE

extern EIF_MUTEX_TYPE *conn_mutex;

struct eif_dscoop_reference {
	EIF_DSCOOP_NID nid;
	EIF_DSCOOP_PID pid;
	EIF_DSCOOP_OID oid;
};

#define RT_CHT_NAMESPACE(suffix) eif_dscoop_proxy_table##suffix
#define RT_CHT_KEY_TYPE struct eif_dscoop_reference
#define RT_CHT_VALUE_TYPE EIF_OBJECT
#include "../include/rt_cuckoo_hash.h"
#undef RT_CHT_NAMESPACE
#undef RT_CHT_KEY_TYPE
#undef RT_CHT_VALUE_TYPE

extern EIF_MUTEX_TYPE *proxyobj_mutex;

struct eif_dscoop_processor_reference {
	EIF_DSCOOP_NID nid;
	EIF_DSCOOP_PID pid;
};

#define RT_CHT_NAMESPACE(suffix) eif_dscoop_proxy_processors_table##suffix
#define RT_CHT_KEY_TYPE struct eif_dscoop_processor_reference
#define RT_CHT_VALUE_TYPE EIF_SCP_PID
#include "../include/rt_cuckoo_hash.h"
#undef RT_CHT_NAMESPACE
#undef RT_CHT_KEY_TYPE
#undef RT_CHT_VALUE_TYPE

extern EIF_MUTEX_TYPE *proxyproc_mutex;

// The table that links object ids with the object reference
#define RT_CHT_NAMESPACE(suffix) eif_dscoop_oid_ref_table##suffix
#define RT_CHT_KEY_TYPE EIF_DSCOOP_OID
#define RT_CHT_VALUE_TYPE EIF_REFERENCE
#include "../include/rt_cuckoo_hash.h"
#undef RT_CHT_NAMESPACE
#undef RT_CHT_KEY_TYPE
#undef RT_CHT_VALUE_TYPE

#define RT_CHT_NAMESPACE(suffix) eif_dscoop_export_table##suffix
#define RT_CHT_KEY_TYPE EIF_DSCOOP_NID
#define RT_CHT_VALUE_TYPE struct eif_dscoop_oid_ref_table
#include "../include/rt_cuckoo_hash.h"
#undef RT_CHT_NAMESPACE
#undef RT_CHT_KEY_TYPE
#undef RT_CHT_VALUE_TYPE

// The table that links objects to object ids
// Currently it requires iteration, it would be great if the garbage collector
// could be made aware of this table and update the keys. This means reconstruction
// of the table, but would speed lookups up drastically.
#define RT_CHT_NAMESPACE(suffix) eif_dscoop_object_oid_table##suffix
#define RT_CHT_KEY_TYPE EIF_REFERENCE
#define RT_CHT_VALUE_TYPE EIF_DSCOOP_OID
#include "../include/rt_cuckoo_hash.h"
#undef RT_CHT_NAMESPACE
#undef RT_CHT_KEY_TYPE
#undef RT_CHT_VALUE_TYPE

// Runtime constants
extern EIF_TYPE_ID proxy_type;
extern EIF_TYPE_ID ESTRING_8_type;
extern EIF_TYPE_ID ESTRING_32_type;
extern EIF_TYPE_ID STRING_8_type;
extern EIF_TYPE_ID STRING_32_type;

struct eif_dscoop_connection* eif_dscoop_get_connection (EIF_NATURAL_64 remote_nid);
void eif_dscoop_release_connection (struct eif_dscoop_connection* connection);

EIF_TYPED_VALUE eif_dscoop_connection_get_remote_index (EIF_NATURAL_64 remote_nid);

// Forward declaration
struct rt_processor;

void eif_dscoop_process_message (struct rt_processor* self, struct eif_dscoop_message* message);

void eif_dscoop_add_call_from_message(struct rt_processor* self, struct eif_dscoop_message* message);

EIF_REFERENCE eif_dscoop_get_proxy (EIF_NATURAL_64 remote_nid, EIF_NATURAL_32 remote_pid, EIF_NATURAL_32 remote_oid, const char *type);
call_data* eif_dscoop_create_scoop_call (EIF_REFERENCE target, EIF_TYPE_INDEX context_class, const char * routine, int argc);
void eif_dscoop_set_call_data_argument (call_data* args, EIF_TYPED_VALUE arg, unsigned n);
EIF_NATURAL_32 eif_dscoop_export_object (EIF_REFERENCE ref, EIF_NATURAL_64 client_nid);
EIF_BOOLEAN eif_dscoop_release_exported_object (EIF_NATURAL_32 oid, EIF_NATURAL_64 client_nid);
EIF_NATURAL_32 rt_dscoop_oid_of_object (EIF_REFERENCE ref);
EIF_REFERENCE rt_dscoop_exported_object (EIF_DSCOOP_NID exported_to, EIF_DSCOOP_OID oid);
void eif_dscoop_send_release (EIF_REFERENCE self);
EIF_NATURAL_32 eif_dscoop_oid_of_proxy (EIF_REFERENCE r);
EIF_NATURAL_32 eif_dscoop_pid_of_proxy (EIF_REFERENCE r);
EIF_NATURAL_64 eif_dscoop_nid_of_proxy (EIF_REFERENCE r);
EIF_REFERENCE eif_dscoop_get_remote_object (EIF_NATURAL_64 nid, EIF_NATURAL_32 pid, EIF_NATURAL_32 oid, const char * type, EIF_DSCOOP_NID requestor);
void rt_dscoop_mark_exported(MARKER marking);
void rt_dscoop_deregister_proxy_processor (EIF_DSCOOP_NID nid, EIF_DSCOOP_PID pid);

/* Connects to a given node and registers the connection. Calls into Eiffel. */
void eif_dscoop_connect (const char* address, EIF_NATURAL_16 port);

void eif_dscoop_transaction_send_revert (struct rt_processor* self, struct rt_processor* proxy_proc);

void eif_dscoop_transaction_revert (struct rt_processor* proxy_proc);


#ifdef	__cplusplus
}
#endif

#endif	/* RT_DSCOOP_H */

