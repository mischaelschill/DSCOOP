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
#define DSCOOP_BUF_SIZE 32
#define DSCOOP_INIT_SIZE 32
#define DSCOOP_MAX_ARGUMENTS 32

#ifdef	__cplusplus
extern "C" {
#endif

union {
	char string[8];
} eif_dscoop_subject_t;
	
// Local data structures
union {
	void (*scoop_pattern) (struct eif_scoop_call_data *);
	int routine_id;
	char *something;
} scoop_data;

//A DSCOOP message, the detailed definition is hidden
struct eif_dscoop_message; 

//struct eif_dscoop_message {
//	char* data;
//	EIF_OBJECT anchor;
//	EIF_NATURAL_64 sender, receiver;
//	size_t length, capacity;
//	EIF_NATURAL_32 id;
//	unsigned index[DSCOOP_MAX_ARGUMENTS];
//	EIF_NATURAL_8 arguments;
//};

struct eif_dscoop_message_request {
	struct eif_dscoop_message *message;
	EIF_MUTEX_TYPE *request_mutex;
	EIF_COND_TYPE *ready;
	EIF_NATURAL_32 id;
	EIF_BOOLEAN is_active;
	EIF_BOOLEAN is_ready;
	EIF_BOOLEAN is_failed;
};

RT_DECLARE_VECTOR_BASE (eif_dscoop_message_requests, struct eif_dscoop_message_request)
RT_DECLARE_VECTOR_SIZE_FUNCTIONS (eif_dscoop_message_requests, struct eif_dscoop_message_request)
RT_DECLARE_VECTOR_ARRAY_FUNCTIONS (eif_dscoop_message_requests, struct eif_dscoop_message_request)
RT_DECLARE_VECTOR_STACK_FUNCTIONS (eif_dscoop_message_requests, struct eif_dscoop_message_request)


struct eif_dscoop_compensation {
	EIF_NATURAL_64 serial_no;
	EIF_OBJECT agent;
};

//RT_DECLARE_VECTOR_BASE (eif_dscoop_compensation_list, struct eif_dscoop_compensation)
//RT_DECLARE_VECTOR_SIZE_FUNCTIONS (eif_dscoop_compensation_list, struct eif_dscoop_compensation)
//RT_DECLARE_VECTOR_ARRAY_FUNCTIONS (eif_dscoop_compensation_list, struct eif_dscoop_compensation)
//RT_DECLARE_VECTOR_STACK_FUNCTIONS (eif_dscoop_compensation_list, struct eif_dscoop_compensation)

RT_DECLARE_VECTOR (eif_dscoop_compensation_list, struct eif_dscoop_compensation)

// Global data structures
struct eif_dscoop_connection {
	EIF_OBJECT index_object;
	EIF_MUTEX_TYPE *send_mutex;
	EIF_MUTEX_TYPE *requests_mutex;
	struct eif_dscoop_message_requests requests;
	EIF_NATURAL_32 requests_count;
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
	EIF_NATURAL_64 remote_nid;
	char *node_address;
	EIF_NATURAL_16 node_port;
};

RT_DECLARE_VECTOR_BASE (eif_dscoop_connection_list_t, struct eif_dscoop_connection*)
RT_DECLARE_VECTOR_SIZE_FUNCTIONS (eif_dscoop_connection_list_t, struct eif_dscoop_connection*)
RT_DECLARE_VECTOR_ARRAY_FUNCTIONS (eif_dscoop_connection_list_t, struct eif_dscoop_connection*)
RT_DECLARE_VECTOR_STACK_FUNCTIONS (eif_dscoop_connection_list_t, struct eif_dscoop_connection*)
extern EIF_MUTEX_TYPE *conn_mutex;

struct eif_dscoop_proxy_mapping {
	EIF_OBJECT proxy_obj;
	EIF_NATURAL_64 remote_nid;
	EIF_NATURAL_32 remote_pid;
	EIF_NATURAL_32 remote_oid;
};

RT_DECLARE_VECTOR_BASE (eif_dscoop_proxy_map_t, struct eif_dscoop_proxy_mapping)
RT_DECLARE_VECTOR_SIZE_FUNCTIONS (eif_dscoop_proxy_map_t, struct eif_dscoop_proxy_mapping)
RT_DECLARE_VECTOR_ARRAY_FUNCTIONS (eif_dscoop_proxy_map_t, struct eif_dscoop_proxy_mapping)
RT_DECLARE_VECTOR_STACK_FUNCTIONS (eif_dscoop_proxy_map_t, struct eif_dscoop_proxy_mapping)
extern EIF_MUTEX_TYPE *proxyobj_mutex;

struct eif_dscoop_proxy_processor_mapping {
	EIF_NATURAL_64 remote_nid;
	EIF_NATURAL_32 remote_pid;
	EIF_SCP_PID proxy_pid;
};

RT_DECLARE_VECTOR_BASE (eif_dscoop_proxy_processor_map_t, struct eif_dscoop_proxy_processor_mapping)
RT_DECLARE_VECTOR_SIZE_FUNCTIONS (eif_dscoop_proxy_processor_map_t, struct eif_dscoop_proxy_processor_mapping)
RT_DECLARE_VECTOR_ARRAY_FUNCTIONS (eif_dscoop_proxy_processor_map_t, struct eif_dscoop_proxy_processor_mapping)
RT_DECLARE_VECTOR_STACK_FUNCTIONS (eif_dscoop_proxy_processor_map_t, struct eif_dscoop_proxy_processor_mapping)
extern EIF_MUTEX_TYPE *proxyproc_mutex;

RT_DECLARE_VECTOR_BASE (eif_natural_64_list, EIF_NATURAL_64)
RT_DECLARE_VECTOR_SIZE_FUNCTIONS (eif_natural_64_list, EIF_NATURAL_64)
RT_DECLARE_VECTOR_ARRAY_FUNCTIONS (eif_natural_64_list, EIF_NATURAL_64)
RT_DECLARE_VECTOR_STACK_FUNCTIONS (eif_natural_64_list, EIF_NATURAL_64)

struct eif_dscoop_exported_object {
	EIF_OBJECT local_obj;
	EIF_NATURAL_32 oid;
	struct eif_natural_64_list clients;
};

RT_DECLARE_VECTOR_BASE (eif_dscoop_exported_objects_t, struct eif_dscoop_exported_object)
RT_DECLARE_VECTOR_SIZE_FUNCTIONS (eif_dscoop_exported_objects_t, struct eif_dscoop_exported_object)
RT_DECLARE_VECTOR_ARRAY_FUNCTIONS (eif_dscoop_exported_objects_t, struct eif_dscoop_exported_object)
RT_DECLARE_VECTOR_STACK_FUNCTIONS (eif_dscoop_exported_objects_t, struct eif_dscoop_exported_object)
extern EIF_MUTEX_TYPE *exported_mutex;

// Runtime constants
extern EIF_TYPE_ID proxy_type;
extern EIF_TYPE_ID ESTRING_8_type;
extern EIF_TYPE_ID ESTRING_32_type;
extern EIF_TYPE_ID STRING_8_type;
extern EIF_TYPE_ID STRING_32_type;

struct eif_dscoop_connection* eif_dscoop_get_connection (EIF_NATURAL_64 remote_nid);

EIF_TYPED_VALUE eif_dscoop_connection_get_remote_index (EIF_NATURAL_64 remote_nid);

// Forward declaration
struct rt_processor;

void eif_dscoop_process_message (struct rt_processor* self, struct eif_dscoop_message* message);

void eif_dscoop_add_call_from_message(struct rt_processor* self, struct eif_dscoop_message* message);

EIF_REFERENCE eif_dscoop_get_proxy (EIF_NATURAL_64 remote_nid, EIF_NATURAL_32 remote_pid, EIF_NATURAL_32 remote_oid, const char *type);
call_data* eif_dscoop_create_scoop_call (EIF_REFERENCE target, EIF_TYPE_INDEX context_class, const char * routine, int argc);
void eif_dscoop_set_call_data_argument (call_data* args, EIF_TYPED_VALUE arg, unsigned n);
EIF_NATURAL_32 eif_dscoop_export_object (EIF_REFERENCE obj, EIF_NATURAL_64 client_nid);
EIF_NATURAL_32 eif_dscoop_get_exported_object_id (EIF_REFERENCE obj, EIF_NATURAL_64 client_nid);
EIF_REFERENCE eif_dscoop_get_exported_object (EIF_NATURAL_32 oid, EIF_NATURAL_64 client_nid);
void eif_dscoop_send_release (EIF_REFERENCE self);
EIF_NATURAL_32 eif_dscoop_oid_of_proxy (EIF_REFERENCE r);
EIF_NATURAL_32 eif_dscoop_pid_of_proxy (EIF_REFERENCE r);
EIF_NATURAL_64 eif_dscoop_nid_of_proxy (EIF_REFERENCE r);
EIF_REFERENCE eif_dscoop_get_remote_object (EIF_NATURAL_64 nid, EIF_NATURAL_32 pid, EIF_NATURAL_32 oid, const char * type, EIF_NATURAL_64 requestor_nid);
void eif_dscoop_connection_decrement_request_count (struct eif_dscoop_connection* connection);

/* Connects to a given node and registers the connection. Calls into Eiffel. */
void eif_dscoop_connect (const char* address, EIF_NATURAL_16 port);

void eif_dscoop_transaction_send_revert (struct rt_processor* self, struct rt_processor* proxy_proc);

void eif_dscoop_transaction_revert (struct rt_processor* proxy_proc);


#ifdef	__cplusplus
}
#endif

#endif	/* RT_DSCOOP_H */

