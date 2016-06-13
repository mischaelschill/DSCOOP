#include "eif_cecil.h"
#include "rt_cecil.h"
#include "rt_dscoop.h"
#include "rt_vector.h"
#include "eif_internal.h"
#include "rt_request_group.h"
#include "rt_gen_types.h"
#include <sys/socket.h>
#include "rt_globals.h"
#include "rt_message.h"
#include "rt_processor.h"
#include "eif_memory.h"
#include "rt_processor_registry.h"
#include "rt_macros.h"
#include "rt_scoop.h"
#include "rt_dscoop_message.h"
#include "rt_struct.h"

RT_DECLARE_VECTOR (eif_pid_list, EIF_DSCOOP_PID)

#define RT_CHT_NAMESPACE(suffix) eif_dscoop_request_table##suffix
#define RT_CHT_KEY_TYPE EIF_NATURAL_32
#define RT_CHT_VALUE_TYPE struct eif_dscoop_message_request*
#include "../cuckoo_hash.c"
#undef RT_CHT_NAMESPACE
#undef RT_CHT_KEY_TYPE
#undef RT_CHT_VALUE_TYPE

#define RT_CHT_NAMESPACE(suffix) eif_dscoop_connection_table##suffix
#define RT_CHT_KEY_TYPE EIF_NATURAL_64
#define RT_CHT_VALUE_TYPE struct eif_dscoop_connection*
#include "../cuckoo_hash.c"
#undef RT_CHT_NAMESPACE
#undef RT_CHT_KEY_TYPE
#undef RT_CHT_VALUE_TYPE

#define RT_CHT_NAMESPACE(suffix) eif_dscoop_oid_ref_table##suffix
#define RT_CHT_KEY_TYPE EIF_DSCOOP_OID
#define RT_CHT_VALUE_TYPE EIF_REFERENCE
#include "../cuckoo_hash.c"
#undef RT_CHT_NAMESPACE
#undef RT_CHT_KEY_TYPE
#undef RT_CHT_VALUE_TYPE

#define RT_CHT_NAMESPACE(suffix) eif_dscoop_export_table##suffix
#define RT_CHT_KEY_TYPE EIF_DSCOOP_NID
#define RT_CHT_VALUE_TYPE struct eif_dscoop_oid_ref_table
#include "../cuckoo_hash.c"
#undef RT_CHT_NAMESPACE
#undef RT_CHT_KEY_TYPE
#undef RT_CHT_VALUE_TYPE

#define RT_CHT_NAMESPACE(suffix) eif_dscoop_object_oid_table##suffix
#define RT_CHT_KEY_TYPE EIF_REFERENCE
#define RT_CHT_VALUE_TYPE EIF_DSCOOP_OID
#include "../cuckoo_hash.c"
#undef RT_CHT_NAMESPACE
#undef RT_CHT_KEY_TYPE
#undef RT_CHT_VALUE_TYPE

#define RT_CHT_NAMESPACE(suffix) eif_dscoop_proxy_table##suffix
#define RT_CHT_KEY_TYPE struct eif_dscoop_reference
#define RT_CHT_KEY_EQUALITY(l, r) \
		l.nid == r.nid && l.pid == r.pid && l.oid == r.oid
#define RT_CHT_HASHCODE(ref) \
		ref.nid + 69046 * ref.pid + 18549 * ref.oid
#define RT_CHT_VALUE_TYPE EIF_OBJECT
#include "../cuckoo_hash.c"
#undef RT_CHT_HASHCODE
#undef RT_CHT_KEY_EQUALITY
#undef RT_CHT_NAMESPACE
#undef RT_CHT_KEY_TYPE
#undef RT_CHT_VALUE_TYPE

#define RT_CHT_NAMESPACE(suffix) eif_dscoop_proxy_processors_table##suffix
#define RT_CHT_KEY_TYPE struct eif_dscoop_processor_reference
#define RT_CHT_KEY_EQUALITY(l, r) \
		l.nid == r.nid && l.pid == r.pid
#define RT_CHT_HASHCODE(ref) \
		ref.nid + 69046 * ref.pid
#define RT_CHT_VALUE_TYPE EIF_SCP_PID
#include "../cuckoo_hash.c"
#include "rt_atomic_int.h"
#undef RT_CHT_HASHCODE
#undef RT_CHT_KEY_EQUALITY
#undef RT_CHT_NAMESPACE
#undef RT_CHT_KEY_TYPE
#undef RT_CHT_VALUE_TYPE

EIF_BOOLEAN eif_dscoop_initialized = EIF_FALSE;

struct eif_dscoop_connection_table eif_dscoop_connections = {0};
struct eif_dscoop_proxy_table eif_dscoop_proxy_table = {0};
struct eif_dscoop_proxy_processors_table eif_dscoop_proxy_processors_table = {0};
struct eif_dscoop_object_oid_table eif_dscoop_object_oid_table = {0};
struct eif_dscoop_export_table eif_dscoop_export_table = {0};

EIF_MUTEX_TYPE *conn_mutex;
EIF_MUTEX_TYPE *proxyobj_mutex;
EIF_MUTEX_TYPE *proxyproc_mutex;
EIF_MUTEX_TYPE *exported_mutex;

EIF_BOOLEAN object_oid_table_need_rehash = EIF_FALSE;

// Runtime constants
EIF_TYPE_ID proxy_type;
EIF_TYPE_ID ESTRING_8_type;
EIF_TYPE_ID ESTRING_32_type;

EIF_BOOLEAN eif_dscoop_print_debug_messages = EIF_FALSE;

// Some helper functions only used here

static EIF_TYPED_VALUE rt_dscoop_scratch_result;

union overhead* HEADERf(EIF_REFERENCE p)	{
	return (((union overhead *) (p))-1);	/* Fetch header address */
}

EIF_BOOLEAN is_forwarded (EIF_REFERENCE p) {
	union overhead* zone = HEADER(p);
	if (zone->ov_size & B_FWD)
		return EIF_TRUE;
	return EIF_FALSE;
}

EIF_REFERENCE eif_accessf (EIF_OBJECT obj) {
	return eif_access (obj);
}

/*
doc:	<routine name="rt_mark_ref" export="private">
doc:		<summary>Mark and update the reference at 'ref'.</summary>
doc:		<param name="marking" type="MARKER">The marker function. Must not be NULL.</param>
doc:		<param name="ref" type="EIF_REFERENCE*">A pointer to the Eiffel reference. Must not be NULL.</param>
doc:		<thread_safety>Not safe</thread_safety>
doc:		<synchronization>Only call during GC.</synchronization>
doc:	</routine>
*/
rt_private void rt_mark_ref (MARKER marking, EIF_REFERENCE *ref)
{
	REQUIRE("marking_not_null", marking);
	REQUIRE("ref_not_null", ref);
	*ref = marking (ref);
}

EIF_TYPE_INDEX Dtype_fun(EIF_REFERENCE x) {
	return Dtype (x);
}

EIF_TYPE_INDEX Dftype_fun(EIF_REFERENCE x) {
	return Dftype (x);
}

// DSCOOP
rt_public EIF_NATURAL_32 eif_dscoop_oid_of_proxy (EIF_REFERENCE r)
{
	REQUIRE ("r_not_void", r);
	REQUIRE ("r_is_proxy", Dtype(r) == eif_get_eif_dscoop_proxy_dtype ());
	return ei_uint_32_field (0, r);
}

rt_public EIF_NATURAL_32 eif_dscoop_pid_of_proxy (EIF_REFERENCE r)
{
	REQUIRE ("r_not_void", r);
	REQUIRE ("r_is_proxy", Dtype(r) == eif_get_eif_dscoop_proxy_dtype ());
	return rt_get_processor (RTS_PID(r))->remote_pid;
}

rt_public EIF_NATURAL_64 eif_dscoop_nid_of_proxy (EIF_REFERENCE r)
{
	REQUIRE ("r_not_void", r);
	REQUIRE ("r_is_proxy", Dtype(r) == eif_get_eif_dscoop_proxy_dtype ());
	return rt_get_processor (RTS_PID(r))->connection->remote_nid;
}

struct eif_dscoop_connection* eif_dscoop_connection_of_proxy (EIF_REFERENCE r)
{
	REQUIRE ("r_not_void", r);
	return rt_get_processor (RTS_PID(r))->connection;
}

void eif_dscoop_connection_deinit (struct eif_dscoop_connection * connection)
{
	free (connection->node_address);
	eif_pthread_mutex_destroy (connection->requests_mutex);
	eif_pthread_mutex_destroy (connection->send_mutex);
	eif_dscoop_request_table_deinit (&connection->requests);
	//TODO: Remove the connection from the "eiffel" server.
}

//TODO: put this in the right rt_...h file, maybe rt_scoop_helpers?
void eif_scoop_prepare_separate_call (EIF_SCP_PID client_processor_id, EIF_SCP_PID client_region_id, struct eif_scoop_call_data* call);

rt_public void eif_dscoop_log_call (EIF_SCP_PID client_processor_id, EIF_SCP_PID client_region_id, call_data *data)
{
	REQUIRE("has data", data);
	EIF_GET_CONTEXT

	RT_GC_PROTECT (data->target);
	int refargs = 1;
	for (unsigned i = 0; i < data->count; i++) {
		if (data->argument[i].type == SK_REF && data->argument[i].item.r) {
			refargs++;
			RT_GC_PROTECT (data->argument[i].item.r);
		}
	}	
	
	struct rt_processor *client = rt_get_processor (client_region_id);
	struct rt_processor *supplier = rt_get_processor (RTS_PID(data->target));
	struct rt_private_queue *pq = NULL;
	
		/* Calculate whether this call is synchronous. */
	eif_scoop_prepare_separate_call (client_processor_id, client_region_id, data);

	struct eif_dscoop_message message;
	EIF_BOOLEAN expects_result = EIF_FALSE;
	if (data->is_synchronous) {
		if (data->result){
			expects_result = EIF_TRUE;
			eif_dscoop_message_init (&message, S_QCALL, supplier->connection->remote_nid);
		} else {
			eif_dscoop_message_init (&message, S_SCALL, supplier->connection->remote_nid);
		} 
	} else {
		eif_dscoop_message_init (&message, S_CALL, supplier->connection->remote_nid);
	}

	int error = T_OK;
	error = rt_queue_cache_retrieve (&client->cache, supplier, &pq);
	if (error != T_OK) {
		free (data);
		eif_dscoop_message_dispose (&message);
		RT_GC_WEAN_N (refargs);
		enomem();
	}

	eif_dscoop_message_add_natural_argument (&message, client_region_id);
	eif_dscoop_message_add_natural_argument (&message, eif_dscoop_oid_of_proxy (data->target));
	eif_dscoop_message_add_identifier_argument (&message, data->class_name);
	eif_dscoop_message_add_identifier_argument (&message, data->feature_name);
	
	struct foreign_reference {
		EIF_NATURAL_64 nid;
		EIF_NATURAL_32 oid;
	};
	
	struct foreign_reference* foreign_references = malloc (data->count * sizeof (struct foreign_reference));
	unsigned foreign_references_count = 0;
	
	for (unsigned i = 0; i < data->count; i++) {
		eif_dscoop_message_add_value_argument (&message, &data->argument[i]);
		if (data->argument[i].item.r && data->argument[i].type == SK_REF && Dtype(data->argument[i].item.r) == eif_get_eif_dscoop_proxy_dtype()) {
			EIF_NATURAL_64 nid = eif_dscoop_nid_of_proxy (data->argument[i].item.r);
			if (nid != eif_dscoop_node_id () && nid != supplier->connection->remote_nid) {
				foreign_references[foreign_references_count++] = (struct foreign_reference){
					nid, eif_dscoop_oid_of_proxy (data->argument[i].item.r)};
				struct eif_dscoop_connection* connection = eif_dscoop_get_connection (nid);
				if (connection && connection->node_address) {
					eif_dscoop_message_add_node_argument (&message, nid, connection->node_address, connection->node_port);
				}
				eif_dscoop_release_connection (connection);
			}
		}
	}
	#ifdef WORKBENCH
		EIF_TYPED_VALUE* result = data->result;
	#else
		void* result = data->result;
	#endif
	free (data);
	RT_GC_WEAN_N (refargs);
	refargs = 0;
	
	// TODO: First send all messages, then receive them
	for (unsigned i = 0; i < foreign_references_count; i++) {
		EIF_NATURAL_64 nid = foreign_references[i].nid;
		EIF_NATURAL_32 oid = foreign_references[i].oid;
		struct eif_dscoop_message share_msg;
		eif_dscoop_message_init (&share_msg, S_SHARE, nid);
		eif_dscoop_message_add_natural_argument (&share_msg, oid);
		eif_dscoop_message_add_natural_argument (&share_msg, supplier->connection->remote_nid);
		if (eif_dscoop_message_send_receive (&share_msg) || !eif_dscoop_message_ok (&share_msg)) {
			error = EIF_TRUE;
		}
		eif_dscoop_message_dispose (&share_msg);
	}
	free(foreign_references);
	
	if (error != T_OK) {
		eif_dscoop_message_dispose (&message);
		eraise ("Error passing remote reference", EN_PROG);
	}
	
	if (eif_dscoop_message_send_receive (&message) || !eif_dscoop_message_ok (&message)) {
		eif_dscoop_message_dispose (&message);
		eraise ("External call failed", EN_PROG);
	}
	
	if (expects_result) {
		// We expect a result, so we try to get it
		if (eif_dscoop_message_argument_count (&message) > 0 && eif_dscoop_message_is_argument_value (&message, 0)) {
			if (eif_dscoop_message_argument_count (&message) >= 2) {
				if (eif_dscoop_message_get_argument_type (&message, 1) == A_NODE) {
					char *address = NULL;
					EIF_NATURAL_16 port = 0;
					EIF_NATURAL_64 nid = 
							eif_dscoop_message_get_node_argument (&message, 1, &address, &port);

					eif_pthread_mutex_lock (conn_mutex);
					EIF_BOOLEAN has_connection = eif_dscoop_connection_table_has (&eif_dscoop_connections, nid);
					eif_pthread_mutex_unlock (conn_mutex);					
					if (address && port && nid && !has_connection) {
						eif_dscoop_connect (address, port);
					}
					free (address);
				}
			}
			EIF_TYPED_VALUE t = eif_dscoop_message_get_value_argument (&message, 0);
			#ifdef WORKBENCH
				(*result) = t;
			#else
				switch (t.type) {
					case SK_REF:
						*(EIF_REFERENCE *)result = t.item.r;
						break;
					case SK_INT8:
						*(EIF_INTEGER_8 *)result = t.item.i1;
						break;
					case SK_INT16:
						*(EIF_INTEGER_16 *)result = t.item.i2;
						break;
					case SK_INT32:
						*(EIF_INTEGER_32 *)result = t.item.i4;
						break;
					case SK_INT64:
						*(EIF_INTEGER_64 *)result = t.item.i8;
						break;
					case SK_UINT8:
						*(EIF_NATURAL_8 *)result = t.item.n1;
						break;
					case SK_UINT16:
						*(EIF_NATURAL_16 *)result = t.item.n2;
						break;
					case SK_UINT32:
						*(EIF_NATURAL_32 *)result = t.item.n4;
						break;
					case SK_UINT64:
						*(EIF_NATURAL_64 *)result = t.item.n8;
						break;
					case SK_REAL32:
						*(EIF_INTEGER_32 *)result = t.item.r4;
						break;
					case SK_REAL64:
						*(EIF_REAL_64 *)result = t.item.r8;
						break;
					case SK_CHAR8:
						*(EIF_CHARACTER_8 *)result = t.item.c1;
						break;
					case SK_CHAR32:
						*(EIF_CHARACTER_32 *)result = t.item.c4;
						break;
					case SK_BOOL:
						*(EIF_BOOLEAN *)result = t.item.b;
						break;
					case SK_POINTER:
						*(EIF_POINTER *)result = t.item.p;
						break;
				}
			#endif
		} else {
			eif_dscoop_message_dispose (&message);
			eraise ("Query yielded no result", EN_PROG);
		}
	}
	eif_dscoop_message_dispose (&message);
}

rt_public void eif_dscoop_init () {
	if (!eif_dscoop_initialized)
	{
		proxy_type = eif_type_id ("DSCOOP_PROXY_OBJECT");
		ESTRING_8_type = eif_type_id ("ESTRING_8");
		ESTRING_32_type = eif_type_id ("ESTRING_32");

		eif_dscoop_connection_table_init (&eif_dscoop_connections, 0);
		eif_pthread_mutex_create (&conn_mutex);
		eif_dscoop_proxy_table_init (&eif_dscoop_proxy_table, 0);
		eif_pthread_mutex_create (&proxyobj_mutex);
		eif_dscoop_proxy_processors_table_init (&eif_dscoop_proxy_processors_table, 0);
		eif_pthread_mutex_create (&proxyproc_mutex);
		eif_dscoop_object_oid_table_init (&eif_dscoop_object_oid_table, 0);
		eif_dscoop_export_table_init (&eif_dscoop_export_table, 0);
		eif_pthread_mutex_create (&exported_mutex);
		eif_dscoop_initialized = EIF_TRUE;
//		signal(SIGPIPE, SIG_IGN); 
	}
}

rt_public EIF_POINTER eif_dscoop_add_connection (EIF_NATURAL_64 remote_nid, int socket, const char *node_address, EIF_NATURAL_16 node_port)
{
	struct eif_dscoop_connection* connection = malloc (sizeof (struct eif_dscoop_connection));
	
	connection->socket = socket;
	connection->remote_nid = remote_nid;
	eif_pthread_mutex_create (&connection->send_mutex);
	eif_pthread_mutex_create (&connection->requests_mutex);
	eif_dscoop_request_table_init (&connection->requests, 0);
	
	connection->buffer.offset = 0;
	connection->buffer.len = 0;
	connection->index_object_ref = NULL;
	connection->reference_count = 0;
	if (node_address) {
		connection->node_address = malloc (strlen (node_address) + 1);
		strcpy(connection->node_address, node_address);
	} else {
		connection->node_address = NULL;
	}
	connection->node_port = node_port;
	
	eif_pthread_mutex_lock (conn_mutex);
	if (eif_dscoop_connection_table_has (&eif_dscoop_connections, connection->remote_nid)) {
		eif_dscoop_connection_deinit (connection);
	} else {
		eif_dscoop_connection_table_extend (&eif_dscoop_connections, connection->remote_nid, connection);
	}
	eif_pthread_mutex_unlock (conn_mutex);
	return connection;
}

rt_public void eif_dscoop_remove_connection (EIF_NATURAL_64 remote_nid)
{
	eif_pthread_mutex_lock (conn_mutex);
	
	struct eif_dscoop_connection* connection = NULL;
	if (eif_dscoop_connection_table_has(&eif_dscoop_connections, remote_nid)) {
		eif_dscoop_connection_table_remove (&eif_dscoop_connections, remote_nid, &connection);
	}
	
	eif_pthread_mutex_unlock (conn_mutex);

	if (connection) {
		connection->reference_count++;
		// Remove exported objects
		
		eif_pthread_mutex_lock (exported_mutex);
		{
			struct eif_dscoop_oid_ref_table* table = 
					eif_dscoop_export_table_item_pointer (&eif_dscoop_export_table, connection->remote_nid);
			if (table) {
				eif_dscoop_oid_ref_table_deinit (table);
				eif_dscoop_export_table_remove (&eif_dscoop_export_table, connection->remote_nid, NULL);
			}
		} 
		eif_pthread_mutex_unlock (exported_mutex);

		// Wake up waiting clients, they will get an exception.
		eif_pthread_mutex_lock (connection->requests_mutex);
		
		struct eif_dscoop_request_table_iterator it
				= eif_dscoop_request_table_iterator (&connection->requests);
		while (!eif_dscoop_request_table_iterator_after (&it)) {
			struct eif_dscoop_message_request* r = eif_dscoop_request_table_iterator_item (&it);
			eif_pthread_mutex_lock (r->request_mutex);
			r->is_failed = EIF_TRUE;
			eif_pthread_cond_signal (r->ready);
			eif_pthread_mutex_unlock (r->request_mutex);
		}
		eif_dscoop_request_table_wipe_out (&connection->requests);
		eif_pthread_mutex_unlock (connection->requests_mutex);
		eif_dscoop_release_connection (connection);

		#ifdef WORKBENCH
			static void (*DSCOOP_remove_connection)(EIF_REFERENCE, EIF_TYPED_VALUE) = NULL;
		#else
			static void (*DSCOOP_remove_connection)(EIF_REFERENCE, EIF_NATURAL_64) = NULL;
		#endif
		static EIF_TYPE_ID eif_dscoop_tid;
		if (DSCOOP_remove_connection == NULL) {
			eif_dscoop_tid = eif_type_id ("DSCOOP");
			struct eif_define def = eif_find_feature ("remove_connection", eif_dscoop_tid, eif_dscoop_tid);	
		#ifdef WORKBENCH
			DSCOOP_remove_connection = (void (*)(EIF_REFERENCE, EIF_TYPED_VALUE)) def.routine;
		#else
			DSCOOP_remove_connection = (void (*)(EIF_REFERENCE, EIF_NATURAL_64)) def.routine;
		#endif
		}
		#ifdef WORKBENCH
			EIF_TYPED_VALUE nid_val;
			nid_val.type = SK_UINT64;
			nid_val.item.n8 = remote_nid;
			DSCOOP_remove_connection(eif_wean(eif_create (eif_dscoop_tid)), nid_val);
		#else
			DSCOOP_remove_connection(eif_wean(eif_create (eif_dscoop_tid)), remote_nid);
		#endif
	}
}

rt_public EIF_POINTER eif_dscoop_register_connection (EIF_INTEGER_32 fd, EIF_NATURAL_64 remote_nid, const char *node_address, EIF_NATURAL_16 node_port)
{
	return eif_dscoop_add_connection (remote_nid, fd, node_address, node_port);
}

rt_public void eif_dscoop_deregister_connection (EIF_NATURAL_64 remote_nid)
{
	eif_dscoop_remove_connection (remote_nid);
}

struct eif_dscoop_connection* eif_dscoop_get_connection (EIF_NATURAL_64 remote_nid)
{
	eif_pthread_mutex_lock (conn_mutex);
	struct eif_dscoop_connection* result = NULL;
	if (eif_dscoop_connection_table_has (&eif_dscoop_connections, remote_nid)) {
		result = eif_dscoop_connection_table_item (&eif_dscoop_connections, remote_nid);
	}
	eif_pthread_mutex_unlock (conn_mutex);
	return result;
}

void eif_dscoop_release_connection (struct eif_dscoop_connection* connection)
{
	if (connection) {
		eif_pthread_mutex_lock (conn_mutex);
		if (0 == --connection->reference_count && !connection->socket && connection->requests.count == 0) {
			eif_dscoop_connection_deinit (connection);
		}
		eif_pthread_mutex_unlock (conn_mutex);
	}
}

rt_public int eif_dscoop_get_proxy_processor (EIF_REFERENCE* result, struct eif_dscoop_connection* connection, EIF_NATURAL_32 remote_pid) 
{
	EIF_SCP_PID proxy_pid = EIF_NULL_PROCESSOR;
	EIF_ENTER_C; // This lock may be held while waiting for GC, so we need to yield to the GC
	eif_pthread_mutex_lock (proxyproc_mutex);
	EIF_EXIT_C;
	
	struct eif_dscoop_processor_reference pref = {
		connection->remote_nid, remote_pid
	};
	
	// First we create an anchor
	*result = emalloc (egc_any_dtype);
	if (eif_dscoop_proxy_processors_table_has (&eif_dscoop_proxy_processors_table, pref)) {
		proxy_pid = eif_dscoop_proxy_processors_table_item (&eif_dscoop_proxy_processors_table, pref);
		RTS_PID (*result) = proxy_pid;
	}
	
	int error = T_OK;
	
	if (proxy_pid == EIF_NULL_PROCESSOR) {
		// There exist no proxy processor, so we create one
		
		// First we create the region
		error = rt_processor_registry_create_region (&proxy_pid, EIF_FALSE);

		if (error) {
			*result = NULL;
		} else {
			RTS_PID (*result) = proxy_pid;

			// Starting the processor
			rt_processor_registry_activate (proxy_pid);

			// Changing the processor to a proxy processor:
			struct rt_processor* proc = rt_get_processor (proxy_pid);
			proc->connection = connection;
			proc->remote_pid = remote_pid;

			// Adding the proxy processor to the proxy processor table
			eif_dscoop_proxy_processors_table_extend (
					&eif_dscoop_proxy_processors_table, 
					pref, proxy_pid);
		}
	}
	eif_pthread_mutex_unlock (proxyproc_mutex);

	return error;
}

// Retrieves the proxy object for the given sei reference and type
// Creates the proxy object and processor as needed
rt_public EIF_REFERENCE eif_dscoop_get_proxy (EIF_NATURAL_64 remote_nid, EIF_NATURAL_32 remote_pid, EIF_NATURAL_32 remote_oid, const char *type)
{
	EIF_GET_CONTEXT
			
	struct eif_dscoop_connection * connection = eif_dscoop_get_connection (remote_nid);
	EIF_ENCODED_TYPE tid = eif_type_id ((char *)type);
	
	if (!connection || tid == EIF_NO_TYPE) {
		return NULL;
	}

	EIF_REFERENCE result = NULL;
	RT_GC_PROTECT (result);
	
	EIF_ENTER_C;
	eif_pthread_mutex_lock (proxyobj_mutex);
	EIF_EXIT_C;

	struct eif_dscoop_reference ref = {
		remote_nid, remote_pid, remote_oid
	};
	
	EIF_OBJECT weak_result = eif_dscoop_proxy_table_item (&eif_dscoop_proxy_table, ref);
	if (weak_result) {
		result = eif_accessf (weak_result);
		if (!result) {
			// There was a proxy object of the correct type, but it since got collected
			// So we remove the entry from the table
			eif_wean (weak_result);
			eif_dscoop_proxy_table_remove (&eif_dscoop_proxy_table, ref, NULL);
		}
	}
	
	if (!result) {
		// All proxy objects are actually from type DSCOOP_PROXY_OBJECT
		result = emalloc(eif_decoded_type(eif_get_eif_dscoop_proxy_dtype ()).id);
		eif_dscoop_proxy_table_extend (&eif_dscoop_proxy_table, ref, eif_create_weak_reference (result));
		// But they appear to be from the type specified by the server
		union overhead *zone = HEADER(result);
		zone->ov_dftype = eif_decoded_type(tid).id;
		ei_set_natural_32_field (0, result, remote_oid);

		EIF_REFERENCE anchor = NULL;
		RT_GC_PROTECT (anchor);
		// This call invalidates unprotected references!
		int error = eif_dscoop_get_proxy_processor (&anchor, connection, remote_pid);
		if (!error) {
			RTS_PID (result) = RTS_PID (anchor);
		}
		// We do not need the anchor anymore, since we have the proxy object in place
		RT_GC_WEAN (anchor);
	}
	eif_dscoop_release_connection (connection);
	eif_pthread_mutex_unlock (proxyobj_mutex);
	RT_GC_WEAN (result);
	return result;
}

RT_DECLARE_VECTOR_SIZE_FUNCTIONS (rt_request_group, struct rt_private_queue*)
RT_DECLARE_VECTOR_ARRAY_FUNCTIONS (rt_request_group, struct rt_private_queue*)
RT_DECLARE_VECTOR_STACK_FUNCTIONS (rt_request_group, struct rt_private_queue*)

struct eif_dscoop_lookup_cache_line {
	const char* feature;
	EIF_TYPE_ID target;
	EIF_TYPE_ID context;
	struct eif_define def;
	EIF_NATURAL_64 lru;
};
#define cache_size 20
static __thread int cache_count = 0;
static __thread EIF_NATURAL_64 lru = 0;
static __thread struct eif_dscoop_lookup_cache_line lookup_cache[cache_size];

int compare_cache_line (struct eif_dscoop_lookup_cache_line* one, struct eif_dscoop_lookup_cache_line* another) {
	if (one->target > another->target) {
		return 1;
	} else if (one->target < another->target) {
		return -1;
	} else {
		if (one->context > another->context) {
			return 1;
		} else if (one->context < another->context) {
			return -1;
		} else {
			return strcmp (one->feature, another->feature);
		}
	}
}

int eif_dscoop_cache_lookup (struct eif_define* result, const char* feature, EIF_TYPE_ID target, EIF_TYPE_ID context, int lower, int upper) {
	if (lower > upper) {
		(*result) = eif_find_feature (feature, target, context);
		if (cache_count == cache_size) {
			int oldest = 0;
			for (int i = 1; i < cache_count; i++) {
				if (lookup_cache[oldest].lru > lookup_cache[i].lru) {
					oldest = i;
				}
			}
			free ((void *)lookup_cache[oldest].feature);
			for (int i = oldest + 1; i < cache_count; i++) {
				lookup_cache[i - 1] = lookup_cache[i];
			}
			cache_count--;
		}
		for (int i = cache_count; i > lower; i--) {
			lookup_cache[i] = lookup_cache[i-1];
		}
		cache_count++;
		char* featurename = malloc(strlen(feature) + 1);
		strcpy (featurename, feature);
		lookup_cache[lower].feature = featurename;
		lookup_cache[lower].target = target;
		lookup_cache[lower].context = context;
		lookup_cache[lower].def = *result;
		lookup_cache[lower].lru = ++lru;
		return lower;
	} else {
		int mid = (lower + upper)/2;
		struct eif_dscoop_lookup_cache_line needle = {
			feature,
			target,
			context,
			{NULL, NULL, NULL
#ifdef WORKBENCH
	, 0
#endif
			}, 0};
		int res = compare_cache_line (&needle, &lookup_cache[mid]);
		if (res < 0) {
			return eif_dscoop_cache_lookup (result, feature, target, context, lower, mid - 1);
		} else if (res > 0) {
			return eif_dscoop_cache_lookup (result, feature, target, context, mid + 1, upper);
		} else {
			(*result) = lookup_cache[mid].def;
			lookup_cache[mid].lru = ++lru;
			return mid;
		}
	}	
}

/**
 * Creates a new scoop call to target. The routine is given as a string valid
 * in context_class. Arguments are set using `eif_scoop_set_argument'
 * @param target The target of the call
 * @param context_class The class where `feature' points to the correct feature
 * @param feature The feature to call
 * @param argc The number of arguments to reserve.
 * @return The call without arguments.
 */
rt_public call_data* eif_dscoop_create_scoop_call (EIF_REFERENCE target, EIF_TYPE_INDEX context_class, const char * feature, int argc)
{
	call_data* l_scoop_call_data = NULL;
	EIF_TYPE_ID target_type = Dftype(target);
	struct eif_define def;
	if (!strcmp("item", feature)) {
		feature = "item";
	}
	eif_dscoop_cache_lookup (&def, feature, target_type, context_class, 0, cache_count - 1);
	
	if (def.name) {
		#ifdef WORKBENCH
			RTS_AC (argc, target);
			l_scoop_call_data->routine_id = def.feature_id;
			l_scoop_call_data->result = NULL;
		#else
			if (def.routine) {
				int sig_argc = eif_feature_argument_count (&def);
				if (sig_argc != argc) {
					return NULL;
				}
				//TODO: Check signature types against actual types
				RTS_AC (argc, target);
				l_scoop_call_data->address = (fnptr) def.routine;
				l_scoop_call_data->pattern = def.signature->scoop_pattern;
				l_scoop_call_data->result = NULL;
			} else if (def.signature && eif_feature_argument_count (&def) == 0 && eif_feature_type (&def) > 0) {
				int ret;
				int offset = eifaddr_offset (target, (char *)def.name, &ret);
				if (ret == EIF_CECIL_OK) {
					RTS_AC (argc, target);
					l_scoop_call_data->offset = offset;
					l_scoop_call_data->pattern = def.signature->scoop_pattern;
					l_scoop_call_data->result = NULL;
				}
			}
		#endif
	}
	return l_scoop_call_data;
}

/**
 * Sets the n-th argument of args to arg.
 * @param args the SCOOP call
 * @param arg the argument to set
 * @param n the index of the argument in the argument list
 */
void eif_dscoop_set_call_data_argument (call_data* args, EIF_TYPED_VALUE arg, unsigned n)
{
	args -> argument [n] = arg;
}

/**
 * Sends a RELEASE message for the object referenced by `self'
 * @param self the object to be released
 */
void eif_dscoop_send_release (EIF_REFERENCE self)
{
	struct eif_dscoop_message message;
	EIF_NATURAL_32 oid = eif_dscoop_oid_of_proxy (self);
	struct eif_dscoop_connection* connection = eif_dscoop_connection_of_proxy (self);
	eif_dscoop_message_init (&message, S_RELEASE, connection->remote_nid);
	eif_dscoop_message_add_natural_argument (&message, oid);
	eif_dscoop_message_send (&message);
	eif_dscoop_message_dispose (&message);
}

/*
 * Release an object exported to `client_nid'. This makes the object available
 * for garbage collecting unless it is exported to some other node or referenced
 * by a local root. It does not remove it from the set of exported objects of
 * the client connection, this has to be done by the caller.
 */
EIF_BOOLEAN eif_dscoop_release_exported_object (EIF_NATURAL_32 oid, EIF_NATURAL_64 client_nid)
{
	eif_pthread_mutex_lock (exported_mutex);
	
	struct eif_dscoop_oid_ref_table* table = 
		eif_dscoop_export_table_item_pointer (&eif_dscoop_export_table, client_nid);
	EIF_BOOLEAN result = EIF_FALSE;
	if (table) {
		result = eif_dscoop_oid_ref_table_remove (table, oid, NULL);
	}
	eif_pthread_mutex_unlock (exported_mutex);
	return result;	
}

EIF_NATURAL_32 eif_dscoop_export_object (EIF_REFERENCE ref, EIF_NATURAL_64 client_nid)
{      
	EIF_OBJECT obj = eif_protect (ref);

	eif_pthread_mutex_lock (exported_mutex);
	EIF_DSCOOP_OID oid = rt_dscoop_oid_of_object (eif_access (obj)); 

	struct eif_dscoop_oid_ref_table* table;
	EIF_BOOLEAN table_exists = eif_dscoop_export_table_has (&eif_dscoop_export_table, client_nid);
	if (table_exists) {
		table = eif_dscoop_export_table_item_pointer (&eif_dscoop_export_table, client_nid);
	} else {
		eif_dscoop_export_table_extend (&eif_dscoop_export_table, client_nid, (struct eif_dscoop_oid_ref_table){0});
		table = eif_dscoop_export_table_item_pointer (&eif_dscoop_export_table, client_nid);
		eif_dscoop_oid_ref_table_init (table, 1);
	}
	if (!eif_dscoop_oid_ref_table_has (table, oid)) {
		eif_dscoop_oid_ref_table_extend (table, oid, eif_access (obj));
	}
	eif_pthread_mutex_unlock (exported_mutex);
	eif_wean (obj);
	return oid;
}

EIF_BOOLEAN rt_dscoop_peer_has_access_to_object (EIF_DSCOOP_NID nid, EIF_DSCOOP_OID oid) {

	EIF_BOOLEAN result = EIF_FALSE;
	
	eif_pthread_mutex_lock (exported_mutex);

	struct eif_dscoop_oid_ref_table* table
		= eif_dscoop_export_table_item_pointer (&eif_dscoop_export_table, nid);

	if (table && eif_dscoop_oid_ref_table_has (table, oid)) {
		result = EIF_TRUE;
	}

	eif_pthread_mutex_unlock (exported_mutex);
	
	return result;
}

EIF_DSCOOP_OID rt_dscoop_oid_of_object (EIF_REFERENCE ref)
{                    
	eif_pthread_mutex_lock (exported_mutex);
	static EIF_NATURAL_32 next_oid = 1;
	
	EIF_DSCOOP_OID oid = 0;
	if (object_oid_table_need_rehash) {
		object_oid_table_need_rehash = EIF_FALSE;
		eif_dscoop_object_oid_table_rehash (&eif_dscoop_object_oid_table, 0);
	}
	oid = eif_dscoop_object_oid_table_item (&eif_dscoop_object_oid_table, ref);
	if (!oid) {
		oid = next_oid++;
		eif_dscoop_object_oid_table_extend (&eif_dscoop_object_oid_table, ref, oid);
	}
	
	eif_pthread_mutex_unlock (exported_mutex);
	return oid;
}

EIF_REFERENCE rt_dscoop_exported_object (EIF_DSCOOP_NID nid, EIF_DSCOOP_OID oid) {
	EIF_REFERENCE ref = NULL;
	
	eif_pthread_mutex_lock (exported_mutex);

	struct eif_dscoop_oid_ref_table* table
		= eif_dscoop_export_table_item_pointer (&eif_dscoop_export_table, nid);
	
	if (table) {
		//Checking that the object is actually available for the client
		ref = eif_dscoop_oid_ref_table_item (table, oid);
	}
	
	eif_pthread_mutex_unlock (exported_mutex);
	
	return ref;
}

rt_public EIF_NATURAL_64 eif_dscoop_node_id()
{
	static EIF_NATURAL_64 node_id = 0;
	if (node_id == 0) {
		FILE *stream = fopen ("/dev/random", "r");
		if (stream) {
			fread (&node_id, sizeof(node_id), 1, stream);
			fclose (stream);
		} else {
			eraise ("Unable to retrieve node id", EN_PROG);
		}
	}
	return node_id;
	
}

rt_public EIF_TYPE_ID eif_get_eif_dscoop_proxy_dtype() 
{
	return proxy_type;
}

rt_public EIF_REFERENCE eif_dscoop_get_remote_object (EIF_NATURAL_64 nid, EIF_NATURAL_32 pid, EIF_NATURAL_32 oid, const char * type, EIF_DSCOOP_NID requestor)
{
	if (nid == eif_dscoop_node_id()) {
		return rt_dscoop_exported_object (oid, requestor);
	} else {
		return eif_dscoop_get_proxy (nid, pid, oid, type);
	}
}

rt_public EIF_TYPED_VALUE eif_dscoop_connection_get_remote_index (EIF_NATURAL_64 nid) 
{
	REQUIRE ("name_not_void", name != NULL);
	EIF_TYPED_VALUE result;

	struct eif_dscoop_message message;
	eif_dscoop_message_init (&message, S_INDEX, nid);

	if (eif_dscoop_message_send_receive (&message)) {
		eif_dscoop_message_dispose(&message);
		eraise("DSCOOP connection error.", EN_PROG);
	}
	if (eif_dscoop_message_ok(&message))
	{
		result = eif_dscoop_message_get_value_argument (&message, 0);
	} else {
		result.item.r = NULL;
		result.type = SK_VOID;
	}
	eif_dscoop_message_dispose(&message);
	return result;
}

void eif_dscoop_add_call_from_message (struct rt_processor* self, struct eif_dscoop_message* message)
{
	EIF_GET_CONTEXT;
	
	EIF_NATURAL_32 target_id = eif_dscoop_message_get_natural_argument (message, 1);
	EIF_NATURAL_64 sender = eif_dscoop_message_sender(message);
	
	EIF_BOOLEAN expects_result = eif_dscoop_message_subject (message) == S_QCALL;
	EIF_BOOLEAN expects_synchronization = expects_result || eif_dscoop_message_subject (message) == S_SCALL;
	
	int error = T_OK;
	
	char* cname = eif_dscoop_message_get_identifier_argument (message, 2);
	char* rname = eif_dscoop_message_get_identifier_argument (message, 3);

	int first_argument_index = 4;

	// Extracting target and arguments from the message:
	EIF_TYPED_VALUE* arguments = malloc (sizeof (EIF_TYPED_VALUE) * eif_dscoop_message_argument_count(message) - first_argument_index + 1);
	arguments[0].type = SK_REF;
	arguments[0].item.r = rt_dscoop_exported_object (self->connection->remote_nid, target_id);
	unsigned refvars = 1;
	RT_GC_PROTECT (arguments[0].item.r);

	if (arguments[0].item.r == NULL) {
		error = 1;
	}

	// We store the arguments in a temporary array, so that we can easily protect them
	int argument_count = 0;
	for (int i = first_argument_index; !error && i < eif_dscoop_message_argument_count(message); i++) {
		if (eif_dscoop_message_get_argument_type (message, i) != A_NODE) {
			argument_count++;
			arguments[argument_count].type = SK_INVALID;
			arguments[argument_count] = eif_dscoop_message_get_value_argument(message, i);
			if (arguments[argument_count].type == SK_REF) {
				RT_GC_PROTECT (arguments[argument_count].item.r);
				refvars++;
			} else if (arguments[argument_count].type == SK_INVALID) {
				error = 1;
			}
		} else {
			char* address;
			EIF_NATURAL_16 port = 0;
			EIF_NATURAL_64 nid = eif_dscoop_message_get_node_argument (message, i, &address, &port);

			eif_pthread_mutex_lock (conn_mutex);
			EIF_BOOLEAN has_connection = eif_dscoop_connection_table_has (&eif_dscoop_connections, nid);
			eif_pthread_mutex_unlock (conn_mutex);					
			if (port && nid && address && !has_connection) {
				eif_dscoop_connect (address, port);
			}

			if (address) {
				free (address);
			}
		}
	}
	
	//Find the correct routine
	EIF_TYPED_VALUE result = {0};
	if (!error) {
		struct eif_define def = eif_find_feature (rname, eif_type_by_reference (arguments[0].item.r), 0);
		EIF_TYPE_ID rtype = def.signature->result_type;
		if (rtype != INVALID_DTYPE) {
			result.type = eif_dtype_to_sk_type (rtype);
			if (result.type == SK_REF) {
				result.item.r = NULL;
				RT_GC_PROTECT (result.item.r);
				refvars++;
			}
		} else {
			result.type = SK_INVALID;
		}
	}

	// Building of the call data struct
	call_data* cd = NULL;
	if (!error) {
		EIF_TYPE context_type = eif_type_id2 (cname);
		if (context_type.id == INVALID_DTYPE || !arguments[0].item.r) {
			error = T_INVALID_ARGUMENT;
		} else {
			cd = eif_dscoop_create_scoop_call(arguments[0].item.r, context_type.id, rname, argument_count);
			if (!cd) {
				error = 1;
			} else {
				for (int i = 0; i < argument_count; i++) {
					eif_dscoop_set_call_data_argument (cd, arguments[i+1], i);
				}
			}
			
			if (expects_result) {
				if (result.type != SK_INVALID) {
					#ifndef WORKBENCH
					switch (result.type) {
						case SK_INT8:
							cd -> result = &result.item.i1;
						break;
						case SK_INT16:
							cd -> result = &result.item.i2;
						break;
						case SK_INT32:
							cd -> result = &result.item.i4;
						break;
						case SK_INT64:
							cd -> result = &result.item.i8;
						break;
						case SK_UINT8:
							cd -> result = &result.item.n1;
						break;
						case SK_UINT16:
							cd -> result = &result.item.n2;
						break;
						case SK_UINT32:
							cd -> result = &result.item.n4;
						break;
						case SK_UINT64:
							cd -> result = &result.item.n8;
						break;
						case SK_REAL32:
							cd -> result = &result.item.r4;
						break;
						case SK_REAL64:
							cd -> result = &result.item.r8;
						break;
						case SK_CHAR8:
							cd -> result = &result.item.c1;
						break;
						case SK_CHAR32:
							cd -> result = &result.item.c4;
						break;
						case SK_POINTER:
							cd -> result = &result.item.p;
						break;
						case SK_BOOL:
							cd -> result = &result.item.b;
							break;
						case SK_INVALID:
							cd -> result = NULL;
							break;
						default:
							result.type = SK_REF;
							cd -> result = &result.item.r;
						break;
					}
					#else
						cd -> result = &result;
					#endif
				} else {
					// We expect a result, but this is a procedure!
					error = 1;
				}
			} else {
				if (result.type != SK_INVALID) {
					// This is a function, but the client does not care about 
					// the result
					cd -> result = &rt_dscoop_scratch_result;
				} else {
					// We do not expect a result, and it is a procedure
					cd -> result = NULL;
				}				
			}
		}
	}
	
	// Finally, making the call
	if (!error) {
		cd->is_synchronous = expects_synchronization;
		eif_scoop_log_call (self->pid, self->pid, cd);
		
		// Returning the result, if needed
		if (expects_result) {
			struct eif_dscoop_connection* result_connection = NULL;
			EIF_NATURAL_64 nid = 0;
			switch (result.type) {
				case SK_REF:
					if (Dtype(result.item.r) == eif_get_eif_dscoop_proxy_dtype ()) {
						struct rt_processor* supplier = rt_get_processor (RTS_PID(result.item.r));
						nid = supplier->connection->remote_nid;
						CHECK ("connection_has_nid", nid);
						if (nid != eif_dscoop_node_id () && nid != sender) {
							struct eif_dscoop_message share_msg;
							eif_dscoop_message_init (&share_msg, S_SHARE, nid);
							eif_dscoop_message_add_natural_argument (&share_msg, eif_dscoop_oid_of_proxy (result.item.r));
							eif_dscoop_message_add_natural_argument (&share_msg, sender);
							if (eif_dscoop_message_send_receive (&share_msg) || !eif_dscoop_message_ok (&share_msg)) {
								error = EIF_TRUE;
							}
							eif_dscoop_message_dispose (&share_msg);
							result_connection = eif_dscoop_get_connection (nid);
						}
					}
					break;
				case SK_INVALID:
					error = 1;
					// Fallthrough intended
				case SK_VOID:
					result.type = SK_VOID;
					result.item.r = 0;
					break;
				default:
					break;
			}
			if (!error) {
				eif_dscoop_message_reply (message, S_OK);
				eif_dscoop_message_add_value_argument (message, &result);
				if (result_connection && result_connection->node_address) {
					eif_dscoop_message_add_node_argument (message, nid, result_connection->node_address, result_connection->node_port);
				}
			} else {
				eif_dscoop_message_reply (message, S_FAIL);
			}
			eif_dscoop_release_connection (result_connection);
		} else {
			eif_dscoop_message_reply (message, S_OK);
		}
	} else {
		eif_dscoop_message_reply (message, S_FAIL);
	}
	eif_dscoop_message_send (message);
	eif_dscoop_message_dispose (message);
	if (refvars) {
		RT_GC_WEAN_N (refvars);
	}
	result.type = SK_INVALID;
	result.item.r = NULL;
	free (arguments);
	free (message);
}

struct eif_dscoop_message* eif_dscoop_message_receive_orphan (struct eif_dscoop_connection* connection) {
	struct eif_dscoop_message* result = 0;
	eif_pthread_mutex_lock (connection->default_handler.lock);
	result = connection->default_handler.message;
	while (!result) {
		eif_pthread_cond_wait (connection->default_handler.ready, connection->default_handler.lock);
		result = connection->default_handler.message;
	}
	connection->default_handler.message = 0;
	eif_pthread_cond_signal (connection->default_handler.free);
	eif_pthread_mutex_unlock (connection->default_handler.lock);
	return result;
}

void eif_dscoop_process_message (struct rt_processor* self, struct eif_dscoop_message* message)
{
	switch (eif_dscoop_message_subject (message)) {
		case S_PRELOCK:
			//TODO: Make sure the prelock is followed by a LOCK or else unlock the qoq! Add timeouts.
			// Request: LOCK <client id> <private queue>+
			// Reply: OK
			if (eif_dscoop_message_argument_count (message) >= 2) {
				int error = T_OK;
				rt_processor_request_group_stack_extend (self);
				struct rt_request_group* rg = rt_processor_request_group_stack_last (self);
				for (EIF_NATURAL_8 i = 1; i < eif_dscoop_message_argument_count (message) && !error; i++) {
					// TODO: Make sure the processor actually has exported objects!
					EIF_SCP_PID supplier_pid = eif_dscoop_message_get_natural_argument (message, i);
					struct rt_processor* supplier = rt_lookup_processor (supplier_pid);
					if (supplier) {
						rt_request_group_add (rg, supplier);
					} else {
						error = 1;
						break;
					}
				}
				if (error) {
					rt_processor_request_group_stack_remove (self, 1);
					eif_dscoop_message_reply (message, S_FAIL);
				} else {
					rt_request_group_set_anchor (rg, message->anchor);
					rt_request_group_prelock (rg);
					eif_dscoop_message_reply (message, S_OK);
				}
			} else {
				eif_dscoop_message_reply (message, S_FAIL);
			}
			eif_dscoop_message_send (message);
			eif_dscoop_message_dispose (message);
			free (message);
		break;
		case S_LOCK:
			//TODO: Make sure the lock is eventually unlocked, even with the connection still open, which means adding timeouts.
			// Request: LOCK <client id> <private queue>+
			// Reply: OK
			if (eif_dscoop_message_argument_count (message) >= 2) {
				int error = T_OK;
				rt_processor_request_group_stack_extend (self);
				struct rt_request_group* rg = rt_processor_request_group_stack_last (self);
				for (EIF_NATURAL_8 i = 1; i < eif_dscoop_message_argument_count (message) && !error; i++) {
					// TODO: Make sure the processor actually has exported objects!
					EIF_SCP_PID supplier_pid = eif_dscoop_message_get_natural_argument (message, i);
					struct rt_processor* supplier = rt_lookup_processor (supplier_pid);
					if (supplier) {
						rt_request_group_add (rg, supplier);
					} else {
						error = 1;
						break;
					}
				}
				if (error) {
					rt_processor_request_group_stack_remove (self, 1);
					eif_dscoop_message_reply (message, S_FAIL);
				} else {
					rt_request_group_set_anchor (rg, message->anchor);
					rt_request_group_lock (rg);
					eif_dscoop_message_reply (message, S_OK);
				}
			} else if (eif_dscoop_message_argument_count (message) == 1) {
				struct rt_request_group* rg = rt_processor_request_group_stack_last (self);
				if (!rg->is_locked && rg->is_sorted) {
					rt_request_group_postlock (rg);
					eif_dscoop_message_reply (message, S_OK);
				} else {
					eif_dscoop_message_reply (message, S_FAIL);
				}
			} else {
				eif_dscoop_message_reply (message, S_FAIL);
			}
			eif_dscoop_message_send (message);
			eif_dscoop_message_dispose (message);
			free (message);
		break;
		case S_UNLOCK:
			if (rt_processor_request_group_stack_count (self)) {
				struct rt_request_group *rg = rt_processor_request_group_stack_last (self);
				rt_request_group_unlock (rg, EIF_FALSE);
				rt_processor_request_group_stack_remove (self, 1);
				eif_dscoop_message_reply (message, S_OK);
			} else {
				eif_dscoop_message_reply (message, S_FAIL);
			}
			eif_dscoop_message_send (message);
			eif_dscoop_message_dispose (message);
			free (message);
		break;
		case S_AWAIT:
			if (rt_processor_request_group_stack_count (self)) {
				struct rt_request_group *rg = rt_processor_request_group_stack_last (self);
				eif_dscoop_message_reply (message, S_OK);
				eif_dscoop_message_send (message);
				eif_dscoop_message_reset (message, S_READY, self->connection->remote_nid);
				eif_dscoop_message_add_natural_argument (message, self->remote_pid);
				rt_request_group_wait(rg);
				rt_processor_request_group_stack_remove (self, 1);
				eif_dscoop_message_send (message);
			} else {
				eif_dscoop_message_reply (message, S_FAIL);
				eif_dscoop_message_send (message);
			}
			eif_dscoop_message_dispose (message);
			free (message);
		break;
		case S_CALL:
		case S_QCALL:
		case S_SCALL:
			eif_dscoop_add_call_from_message (self, message);
		break;
		default:
			eif_dscoop_message_dispose (message);
			free (message);
	}
}

rt_public void eif_dscoop_connection_set_index_object (EIF_POINTER connection, EIF_REFERENCE object) 
{
	struct eif_dscoop_connection *c = connection;
	c->index_object_ref = object;
}

rt_public EIF_REFERENCE eif_dscoop_get_remote_index (EIF_NATURAL_64 remote_nid)
{
	EIF_TYPED_VALUE v = eif_dscoop_connection_get_remote_index (remote_nid);
	if (v.type && v.type != SK_INVALID && v.type != SK_VOID)
		return eif_box(v);
	else
		return NULL;
}

EIF_BOOLEAN rt_dscoop_message_handle_one (struct rt_processor* self, struct eif_dscoop_connection* connection)
{
	EIF_GET_CONTEXT
	
	struct eif_dscoop_message* message = malloc (sizeof (struct eif_dscoop_message));
	eif_dscoop_message_init (message, 0, 0);

	if (!eif_dscoop_message_receive_request (connection, message)) {
		// Connection terminated
		eif_dscoop_message_dispose (message);
		free (message);

		// Call revert on all proxy processors belonging to this connection

		// First we need to gather the proxy processors
		struct eif_pid_list list;
		eif_pid_list_init (&list);
		EIF_ENTER_C;
		eif_pthread_mutex_lock (proxyproc_mutex);
		EIF_EXIT_C;
		
		struct eif_dscoop_proxy_processors_table_iterator it =
				eif_dscoop_proxy_processors_table_iterator (&eif_dscoop_proxy_processors_table);
		while (!eif_dscoop_proxy_processors_table_iterator_after (&it)) {
			if (eif_dscoop_proxy_processors_table_iterator_key (&it).nid == connection->remote_nid) {
				eif_pid_list_extend (&list, eif_dscoop_proxy_processors_table_iterator_item (&it));
			}
			eif_dscoop_proxy_processors_table_iterator_forth (&it);
		}
		eif_pthread_mutex_unlock (proxyproc_mutex);

		//Then we instruct them to revert their transactions
		for (size_t i = 0; i < eif_pid_list_count (&list); i++) {
			struct rt_processor* proc = rt_get_processor (eif_pid_list_item (&list, i));
			if (proc && proc->connection && proc->connection->remote_nid == connection->remote_nid) {
				eif_dscoop_transaction_send_revert (self, proc);
			}
		}
		eif_pid_list_deinit (&list);
		
		return EIF_FALSE;
	}
		
	switch (eif_dscoop_message_subject (message)) {
		case S_HELLO:
		{
			//TODO: Support relayed connections.
			struct eif_dscoop_connection* c = eif_dscoop_get_connection (eif_dscoop_message_sender (message));
			if (c) {
				eif_dscoop_message_reply (message, S_OK);
				eif_dscoop_message_add_natural_argument (message, eif_dscoop_node_id ());
				eif_dscoop_message_send (message);
				eif_dscoop_message_dispose (message);
				free (message);
			}
			eif_dscoop_release_connection (c);
		}
			break;
		case S_INDEX:
			if (connection->index_object_ref) {
				eif_dscoop_message_reply (message, S_OK);
				EIF_TYPED_VALUE v;
				v.type = SK_REF;
				v.item.r = connection->index_object_ref;
				RT_GC_PROTECT (v.item.r);
				eif_dscoop_message_add_value_argument (message, &v);
				RT_GC_WEAN (v.item.r);
			} else {
				eif_dscoop_message_reply (message, S_FAIL);
			}
			eif_dscoop_message_send (message);
			eif_dscoop_message_dispose (message);
			free (message);
			break;
		case S_READY:
			if (eif_dscoop_message_argument_count (message) == 1) {
				EIF_SCP_PID pid = eif_dscoop_message_get_natural_argument (message, 0);
				// TODO: Check pid somehow ...
				struct rt_processor* proc = rt_lookup_processor (pid);

				if (proc) {
					eif_pthread_mutex_lock (proc->wait_condition_mutex);
					eif_pthread_cond_signal (proc->wait_condition);
					eif_pthread_mutex_unlock (proc->wait_condition_mutex);
					eif_dscoop_message_reply (message, S_OK);
				} else {
					eif_dscoop_message_reply (message, S_FAIL);
				}
			} else {
				eif_dscoop_message_reply (message, S_FAIL);
			}
			eif_dscoop_message_send (message);
			eif_dscoop_message_dispose (message);
			free (message);
			break;
		case S_SHARE:
			if (eif_dscoop_message_argument_count (message) == 2) {
				EIF_NATURAL_32 oid = eif_dscoop_message_get_natural_argument (message, 0);
				EIF_NATURAL_64 nid = eif_dscoop_message_get_natural_argument (message, 1);
				EIF_REFERENCE ref = rt_dscoop_exported_object (connection->remote_nid, oid);
				RT_GC_PROTECT (ref);
				if (ref) {
					eif_dscoop_export_object (ref, nid);
					eif_dscoop_message_reply (message, S_OK);
				} else {
					eif_dscoop_message_reply (message, S_FAIL);
				}
				RT_GC_WEAN (ref);
			} else {
				eif_dscoop_message_reply (message, S_FAIL);
			}
			eif_dscoop_message_send (message);
			eif_dscoop_message_dispose (message);
			free (message);
			break;
		case S_RELEASE:
			if (eif_dscoop_message_argument_count (message) == 1) {
				EIF_NATURAL_32 oid = eif_dscoop_message_get_natural_argument (message, 0);
				eif_dscoop_release_exported_object (connection->remote_nid, oid);
				eif_dscoop_message_reply (message, S_OK);
			} else {
				eif_dscoop_message_reply (message, S_FAIL);
			}
			eif_dscoop_message_send (message);
			eif_dscoop_message_dispose (message);
			free (message);
			break;
		case S_PRELOCK:
			if (eif_dscoop_message_argument_count (message) > 1) {
				EIF_SCP_PID client_pid = eif_dscoop_message_get_natural_argument (message, 0);
				EIF_REFERENCE anchor = NULL;
				RT_GC_PROTECT (anchor);
				int error = eif_dscoop_get_proxy_processor (&anchor, connection, client_pid);
				message->anchor = eif_protect (anchor);
				RT_GC_WEAN (anchor);
				if (error) {
					eif_dscoop_message_reply (message, S_FAIL);
					eif_dscoop_message_send (message);
					eif_dscoop_message_dispose (message);
					free (message);
				} else {
					struct rt_processor* proc = rt_get_processor (RTS_PID (eif_accessf (message->anchor)));
					rt_message_channel_send (&proc->queue_of_queues, SCOOP_DSCOOP_MESSAGE, self, NULL, NULL, message);

					// It is possible that a PRELOCK is sent while we still wait,
					// so we try to wake up the processor
					eif_pthread_mutex_lock (proc->wait_condition_mutex);
					eif_pthread_cond_signal (proc->wait_condition);
					eif_pthread_mutex_unlock (proc->wait_condition_mutex);
				}
			} else {
				eif_dscoop_message_reply (message, S_FAIL);
				eif_dscoop_message_send (message);
				eif_dscoop_message_dispose (message);
				free (message);
			}
			break;
		case S_LOCK:
			if (eif_dscoop_message_argument_count (message) > 0) {
				EIF_SCP_PID client_pid = eif_dscoop_message_get_natural_argument (message, 0);
				EIF_REFERENCE anchor = NULL;
				RT_GC_PROTECT (anchor);
				int error = eif_dscoop_get_proxy_processor (&anchor, connection, client_pid);
				message->anchor = eif_protect (anchor);
				RT_GC_WEAN (anchor);
				if (error) {
					eif_dscoop_message_reply (message, S_FAIL);
					eif_dscoop_message_send (message);
					eif_dscoop_message_dispose (message);
					free (message);
				} else {
					struct rt_processor* proc = rt_get_processor (RTS_PID (eif_accessf (message->anchor)));
					rt_message_channel_send (&proc->queue_of_queues, SCOOP_DSCOOP_MESSAGE, self, NULL, NULL, message);
				}
			} else {
				eif_dscoop_message_reply (message, S_FAIL);
				eif_dscoop_message_send (message);
				eif_dscoop_message_dispose (message);
				free (message);
			}
			break;
		case S_UNLOCK:
			if (eif_dscoop_message_argument_count (message) == 1) {
				EIF_SCP_PID client_pid = eif_dscoop_message_get_natural_argument (message, 0);
				EIF_REFERENCE anchor = NULL;
				RT_GC_PROTECT (anchor);
				int error = eif_dscoop_get_proxy_processor (&anchor, connection, client_pid);
				message->anchor = eif_protect (anchor);
				RT_GC_WEAN (anchor);
				if (error) {
					eif_dscoop_message_reply (message, S_FAIL);
					eif_dscoop_message_send (message);
					eif_dscoop_message_dispose (message);
					free (message);
				} else {
					struct rt_processor* proc = rt_get_processor (RTS_PID (eif_accessf (message->anchor)));
					rt_message_channel_send (&proc->queue_of_queues, SCOOP_DSCOOP_MESSAGE, self, NULL, NULL, message);
				}
			} else {
				eif_dscoop_message_reply (message, S_FAIL);
				eif_dscoop_message_send (message);
				eif_dscoop_message_dispose (message);
				free (message);
			}
			break;
		case S_AWAIT:
			if (eif_dscoop_message_argument_count (message) == 1) {
				EIF_SCP_PID client_pid = eif_dscoop_message_get_natural_argument (message, 0);
				EIF_REFERENCE anchor = NULL;
				RT_GC_PROTECT (anchor);
				int error = eif_dscoop_get_proxy_processor (&anchor, connection, client_pid);
				message->anchor = eif_protect (anchor);
				RT_GC_WEAN (anchor);
				if (error) {
					eif_dscoop_message_reply (message, S_FAIL);
					eif_dscoop_message_send (message);
					eif_dscoop_message_dispose (message);
					free (message);
				} else {
					struct rt_processor* proc = rt_get_processor (RTS_PID (eif_accessf (message->anchor)));
					rt_message_channel_send (&proc->queue_of_queues, SCOOP_DSCOOP_MESSAGE, self, NULL, NULL, message);
				}
			} else {
				eif_dscoop_message_reply (message, S_FAIL);
				eif_dscoop_message_send (message);
				eif_dscoop_message_dispose (message);
				free (message);
			}
			break;
		case S_CALL:
		case S_QCALL:
		case S_SCALL:
			// Syntax: (S/Q)CALL <client_id> <target> <routine> <argument>*
			if (eif_dscoop_message_argument_count (message) >= 3) {
				EIF_SCP_PID client_pid = eif_dscoop_message_get_natural_argument (message, 0);
				EIF_REFERENCE anchor = NULL;
				RT_GC_PROTECT (anchor);
				int error = eif_dscoop_get_proxy_processor (&anchor, connection, client_pid);
				message->anchor = eif_protect (anchor);
				RT_GC_WEAN (anchor);
				if (error) {
					eif_dscoop_message_reply (message, S_FAIL);
					eif_dscoop_message_send (message);
					eif_dscoop_message_dispose (message);
					free (message);
				} else {
					struct rt_processor* proc = rt_get_processor (RTS_PID (eif_accessf (message->anchor)));
					rt_message_channel_send (&proc->queue_of_queues, SCOOP_DSCOOP_MESSAGE, self, NULL, NULL, message);
				}
			} else {
				eif_dscoop_message_reply (message, S_FAIL);
				eif_dscoop_message_send (message);
				eif_dscoop_message_dispose (message);
				free (message);
			}
			break;
		default:
			// Unknown message, we just ignore it. 
			eif_dscoop_message_dispose (message);
			free (message);
	}
	
	return EIF_TRUE;
}

int eif_dscoop_compensation_compare (struct eif_dscoop_compensation* c1, struct eif_dscoop_compensation* c2) {
	// We can assume that the difference of the serial numbers are less than the integer space
	// We sort ascending!
	return  (int)c1->serial_no - c2->serial_no;
}

#ifdef WORKBENCH
#else
void PROCEDURE_apply_pattern (struct eif_scoop_call_data* data) {
	data->address(data->target);
}
#endif

// Calls the compensation agents, but does not remove them. They are removed during unlock
void eif_dscoop_transaction_send_revert (struct rt_processor* self, struct rt_processor* proxy_proc)
{
	rt_message_channel_send (&proxy_proc->queue_of_queues, SCOOP_MESSAGE_REVERT, self, NULL, NULL, NULL);
	//EIF_GET_CONTEXT;
}
	
void eif_dscoop_transaction_revert (struct rt_processor* self)
{
			//TODO: Send revert message to proxy processor instead
	EIF_TYPE_ID proc_type_id = eif_type_id ("PROCEDURE[TUPLE[]]");
	struct eif_define def = eif_find_feature ("apply",  proc_type_id, proc_type_id);
	
#ifdef WORKBENCH
	int routineid = def.feature_id;
#else
	EIF_PROCEDURE p = def.routine;
#endif
		//TODO: Order the compensations before issuing the calls
	while (rt_processor_request_group_stack_count (self)) {
		struct rt_request_group *rg = rt_processor_request_group_stack_last (self);
		for (size_t j = 0; j < rt_request_group_count (rg); j++) {
			struct rt_private_queue* q = rt_request_group_item (rg, j);
			//Synchronization so that we get all the compensations
			// TODO: rt_private_queue_synchronize is no longer available ...
			//rt_private_queue_synchronize (q, self);
			struct eif_dscoop_compensation_list* registered = &q->compensations;
			for (ssize_t k = eif_dscoop_compensation_list_count (registered) - 1; k >= 0; k--) {
				call_data* l_scoop_call_data = NULL;
				RTS_AC (0, eif_accessf(eif_dscoop_compensation_list_item (registered, k).agent));
#ifdef WORKBENCH
				l_scoop_call_data->routine_id = routineid;
#else
				l_scoop_call_data->address = (fnptr) p;
				l_scoop_call_data->pattern = &PROCEDURE_apply_pattern;
#endif	
				rt_private_queue_log_call(q, self, l_scoop_call_data);
			}
		}
		rt_request_group_unlock (rg, EIF_FALSE);
		rt_processor_request_group_stack_remove (self, 1);
	}
//	//qsort (list.area, list.count, sizeof (struct eif_dscoop_compensation), (__compar_fn_t) eif_dscoop_compensation_compare);
//	// Call agents in reverse order
//	for (ssize_t i = list.count - 1; i >= 0; i--) {
//		p (eif_accessf(list.area[i].agent));
//	}
}

rt_public void eif_dscoop_set_print_debug_messages (EIF_BOOLEAN b) {
	eif_dscoop_print_debug_messages = b;
}

void eif_dscoop_connect(const char* address, EIF_NATURAL_16 port) {
	#ifdef WORKBENCH
		static void (*DSCOOP_establish_connection)(EIF_REFERENCE, EIF_TYPED_VALUE, EIF_TYPED_VALUE) = NULL;
	#else
		static void (*DSCOOP_establish_connection)(EIF_REFERENCE, const char*, EIF_NATURAL_16) = NULL;
	#endif
	static EIF_TYPE_ID eif_dscoop_tid;
	if (DSCOOP_establish_connection == NULL) {
		eif_dscoop_tid = eif_type_id ("DSCOOP");
		struct eif_define def = eif_find_feature ("establish_connection", eif_dscoop_tid, eif_dscoop_tid);	
	#ifdef WORKBENCH
		DSCOOP_establish_connection = (void (*)(EIF_REFERENCE, EIF_TYPED_VALUE, EIF_TYPED_VALUE)) def.routine;
	#else
		DSCOOP_establish_connection = (void (*)(EIF_REFERENCE, const char*, EIF_NATURAL_16)) def.routine;
	#endif
	}
	#ifdef WORKBENCH
		EIF_TYPED_VALUE aval, pval;
		aval.type = SK_POINTER;
		aval.item.p = (void *) address;
		pval.type = SK_UINT16;
		pval.item.n2 = port;
		DSCOOP_establish_connection(eif_wean(eif_create (eif_dscoop_tid)), aval, pval);
	#else
		DSCOOP_establish_connection(eif_wean(eif_create (eif_dscoop_tid)), address, port);
	#endif
}

rt_public void eif_builtin_DSCOOP_PROXY_OBJECT_send_release (EIF_REFERENCE self) 
{
	eif_dscoop_send_release (self);
}

rt_public void eif_builtin_DSCOOP_POSTMAN_process_messages_c (EIF_REFERENCE self, EIF_POINTER connection) 
{
	while (rt_dscoop_message_handle_one (rt_get_processor (RTS_PID(self)), connection)) {
	}
}

rt_public void eif_builtin_DSCOOP_COMPENSATION_SUPPORT_register_compensation(EIF_REFERENCE current, EIF_REFERENCE agent) 
{
	struct rt_processor* proc = rt_get_processor (RTS_PID (current));
	struct eif_dscoop_compensation_list* list = &proc->current_queue->compensations;
	struct eif_dscoop_compensation comp;
	comp.serial_no = rt_processor_next_compensation_no (proc);
	comp.agent = eif_protect (agent);
	eif_dscoop_compensation_list_extend (list, comp);
}

void rt_dscoop_mark_exported(MARKER marking) {
	if (eif_dscoop_initialized) {
		{
			struct eif_dscoop_export_table_iterator it
				= eif_dscoop_export_table_iterator (&eif_dscoop_export_table);

			while (!eif_dscoop_export_table_iterator_after(&it)) {
				struct eif_dscoop_oid_ref_table* table =
					eif_dscoop_export_table_iterator_item_pointer(&it);

				if (table) {
					struct eif_dscoop_oid_ref_table_iterator it2
						= eif_dscoop_oid_ref_table_iterator (table);

					while (!eif_dscoop_oid_ref_table_iterator_after(&it2)) {
						EIF_REFERENCE* rref = eif_dscoop_oid_ref_table_iterator_item_pointer(&it2);
						rt_mark_ref (marking, rref);
						eif_dscoop_oid_ref_table_iterator_forth(&it2);
					}
				}

				eif_dscoop_export_table_iterator_forth(&it);
			}
		}

		{
			struct eif_dscoop_connection_table_iterator it
				= eif_dscoop_connection_table_iterator (&eif_dscoop_connections);

			while (!eif_dscoop_connection_table_iterator_after(&it)) {
				struct eif_dscoop_connection* connection =
					eif_dscoop_connection_table_iterator_item(&it);
				if (connection->index_object_ref) {
					rt_mark_ref (marking, &connection->index_object_ref);
				}
				eif_dscoop_connection_table_iterator_forth(&it);
			}
		}
	}
}

void rt_dscoop_deregister_proxy_processor (EIF_DSCOOP_NID nid, EIF_DSCOOP_PID pid) {
	EIF_ENTER_C;
	eif_pthread_mutex_lock (proxyproc_mutex);
	EIF_EXIT_C;
	struct eif_dscoop_processor_reference pref = {
		nid, pid
	};
	eif_dscoop_proxy_processors_table_remove (&eif_dscoop_proxy_processors_table, pref, NULL);
	eif_pthread_mutex_unlock (proxyproc_mutex);

	// Cleaning up proxy object cache
	EIF_ENTER_C;
	eif_pthread_mutex_lock (proxyobj_mutex);
	EIF_EXIT_C;
	struct eif_dscoop_proxy_table_iterator it = 
		eif_dscoop_proxy_table_iterator (&eif_dscoop_proxy_table);
	while (!eif_dscoop_proxy_table_iterator_after (&it)) {
		if (!eif_accessf (eif_dscoop_proxy_table_iterator_item (&it)) ||
				(eif_dscoop_proxy_table_iterator_key (&it).nid == nid &&
				eif_dscoop_proxy_table_iterator_key (&it).pid == pid)) {
			eif_wean (eif_dscoop_proxy_table_iterator_item (&it));
			eif_dscoop_proxy_table_iterator_remove (&it);
		} else {
			eif_dscoop_proxy_table_iterator_forth (&it);
		}
	}
	eif_pthread_mutex_unlock (proxyobj_mutex);
}


void rt_dscoop_update_weak_references () {
	if (eif_dscoop_initialized) {
		struct eif_dscoop_object_oid_table_iterator it
			= eif_dscoop_object_oid_table_iterator (&eif_dscoop_object_oid_table);

		int generational = rt_g_data.status & GC_FAST;

		while (!eif_dscoop_object_oid_table_iterator_after(&it)) {
			EIF_REFERENCE* object = 
					eif_dscoop_object_oid_table_iterator_key_pointer(&it);

			EIF_REFERENCE before = *object;
			EIF_BOOLEAN removed = EIF_FALSE;

			union overhead* zone = HEADER(*object);
			if (zone->ov_size & B_FWD) {
					/* If the object has moved, update the stack */
				*object = zone->ov_fwd;
			} else if (generational) {
				if ((!(zone->ov_flags & EO_OLD)) && (!(zone->ov_flags & EO_MARK))) {
						/* Object is not alive anymore since it was not marked. */
					eif_dscoop_object_oid_table_iterator_remove (&it);
					removed = EIF_TRUE;
				}
			} else if (!(zone->ov_flags & EO_MARK)) {
					/* Object is not alive anymore since it was not marked. */
				eif_dscoop_object_oid_table_iterator_remove (&it);
				removed = EIF_TRUE;
			}

			if (!removed) {
				object_oid_table_need_rehash = object_oid_table_need_rehash || before != *object;
				eif_dscoop_object_oid_table_iterator_forth(&it);
			}
		}
	}
}
