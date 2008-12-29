note
	description: "Control interfaces. Help file: "
	legal: "See notice at end of class."
	status: "See notice at end of class."
	Note: "Automatically generated by the EiffelCOM Wizard."

deferred class
	IOLE_COMMAND_TARGET_INTERFACE

inherit
	ECOM_INTERFACE

feature -- Status Report

	query_status_user_precondition (pguid_cmd_group: ECOM_GUID; c_cmds: INTEGER; prg_cmds: ARRAY [X_TAG_OLECMD_RECORD]; p_cmd_text: X_TAG_OLECMDTEXT_RECORD): BOOLEAN
			-- User-defined preconditions for `query_status'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	exec_user_precondition (pguid_cmd_group: ECOM_GUID; n_cmd_id: INTEGER; n_cmdexecopt: INTEGER; pva_in: ECOM_VARIANT; pva_out: ECOM_VARIANT): BOOLEAN
			-- User-defined preconditions for `exec'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

feature -- Basic Operations

	query_status (pguid_cmd_group: ECOM_GUID; c_cmds: INTEGER; prg_cmds: ARRAY [X_TAG_OLECMD_RECORD]; p_cmd_text: X_TAG_OLECMDTEXT_RECORD)
			-- No description available.
			-- `pguid_cmd_group' [in].  
			-- `c_cmds' [in].  
			-- `prg_cmds' [in, out].  
			-- `p_cmd_text' [in, out].  
		require
			non_void_pguid_cmd_group: pguid_cmd_group /= Void
			valid_pguid_cmd_group: pguid_cmd_group.item /= default_pointer
			non_void_prg_cmds: prg_cmds /= Void
			non_void_p_cmd_text: p_cmd_text /= Void
			valid_p_cmd_text: p_cmd_text.item /= default_pointer
			query_status_user_precondition: query_status_user_precondition (pguid_cmd_group, c_cmds, prg_cmds, p_cmd_text)
		deferred

		end

	exec (pguid_cmd_group: ECOM_GUID; n_cmd_id: INTEGER; n_cmdexecopt: INTEGER; pva_in: ECOM_VARIANT; pva_out: ECOM_VARIANT)
			-- No description available.
			-- `pguid_cmd_group' [in].  
			-- `n_cmd_id' [in].  
			-- `n_cmdexecopt' [in].  
			-- `pva_in' [in].  
			-- `pva_out' [in, out].  
		require
			non_void_pguid_cmd_group: pguid_cmd_group /= Void
			valid_pguid_cmd_group: pguid_cmd_group.item /= default_pointer
			non_void_pva_in: pva_in /= Void
			valid_pva_in: pva_in.item /= default_pointer
			non_void_pva_out: pva_out /= Void
			valid_pva_out: pva_out.item /= default_pointer
			exec_user_precondition: exec_user_precondition (pguid_cmd_group, n_cmd_id, n_cmdexecopt, pva_in, pva_out)
		deferred

		end

note
	copyright:	"Copyright (c) 1984-2006, Eiffel Software and others"
	license:	"Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			 Eiffel Software
			 356 Storke Road, Goleta, CA 93117 USA
			 Telephone 805-685-1006, Fax 805-685-6869
			 Website http://www.eiffel.com
			 Customer support http://support.eiffel.com
		]"




end -- IOLE_COMMAND_TARGET_INTERFACE

