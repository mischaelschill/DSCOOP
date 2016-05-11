/* 
 * File:   eif_dscoop.h
 * Author: Mischael Schill <mischael.schill@inf.ethz.ch>
 *
 * Created on July 22, 2015, 3:14 PM
 */

#ifndef EIF_DSCOOP_H
#define	EIF_DSCOOP_H

#ifdef	__cplusplus
extern "C" {
#endif

#ifdef EIF_THREADS
#include "eif_scoop.h"

struct remote_agent{
	const char* class_name;
	const char* routine_name;
	EIF_NATURAL_16 argument_count;
		/**
		 * The arguments of the remote agent, the first is the target.
		 * Open arguments have type SK_INVALID
		 **/
	EIF_TYPED_VALUE arguments[1];
};	
	
/* SCOOP External Interface */
RT_LNK void eif_dscoop_init();
RT_LNK void eif_dscoop_log_call (EIF_SCP_PID client_processor_id, EIF_SCP_PID client_region_id, call_data *data);
RT_LNK EIF_POINTER eif_dscoop_register_connection (EIF_INTEGER_32 fd, EIF_NATURAL_64 remote_nid, const char *node_address, EIF_NATURAL_16 node_port);
RT_LNK void eif_dscoop_deregister_connection (EIF_NATURAL_64 remote_nid);
RT_LNK void eif_dscoop_connection_set_index_object (EIF_POINTER connection, EIF_REFERENCE object);
RT_LNK EIF_NATURAL_64 eif_dscoop_node_id ();
RT_LNK EIF_REFERENCE eif_dscoop_get_remote_index (EIF_NATURAL_64 remote_nid);
RT_LNK void eif_dscoop_set_print_debug_messages (EIF_BOOLEAN b);

RT_LNK void eif_builtin_DSCOOP_PROXY_OBJECT_send_release (EIF_REFERENCE current);
RT_LNK EIF_INTEGER eif_builtin_DSCOOP_POSTMAN_process_message_c (EIF_REFERENCE self, EIF_POINTER connection);
RT_LNK void eif_builtin_DSCOOP_COMPENSATION_SUPPORT_register_compensation (EIF_REFERENCE current, EIF_REFERENCE agent);
#endif

#ifdef	__cplusplus
}
#endif

#endif	/* EIF_DSCOOP_H */

