note
	description: "Abstract base class for any runnable work item that can be scheduled by the task scheduler. Task Scheduler."
	generator: "Automatically generated by the EiffelCOM Wizard."

deferred class
	ISCHEDULED_WORK_ITEM_INTERFACE

inherit
	ECOM_INTERFACE

feature -- Basic Operations

	create_trigger (pi_new_trigger: INTEGER_REF; pp_trigger: CELL [ITASK_TRIGGER_INTERFACE])
			-- Creates a trigger using a work item object.
			-- `pi_new_trigger' [out].  
			-- `pp_trigger' [out].  
		require
			attached_pi_new_trigger: pi_new_trigger /= Void
			attached_pp_trigger: pp_trigger /= Void
		deferred

		ensure
			valid_pp_trigger: pp_trigger.item /= Void
		end

	delete_trigger (i_trigger: INTEGER)
			-- Deletes a trigger from a work item. 
			-- `i_trigger' [in].  
		deferred

		end

	get_trigger_count (pw_count: INTEGER_REF)
			-- Retrieves the number of triggers associated with a work item.
			-- `pw_count' [out].  
		require
			attached_pw_count: pw_count /= Void
		deferred

		end

	get_trigger (i_trigger: INTEGER; pp_trigger: CELL [ITASK_TRIGGER_INTERFACE])
			-- Retrieves a trigger structure.
			-- `i_trigger' [in].  
			-- `pp_trigger' [out].  
		require
			attached_pp_trigger: pp_trigger /= Void
		deferred

		ensure
			valid_pp_trigger: pp_trigger.item /= Void
		end

	get_trigger_string (i_trigger: INTEGER; ppwsz_trigger: CELL [STRING])
			-- Retrieves a trigger string.
			-- `i_trigger' [in].  
			-- `ppwsz_trigger' [out].  
		require
			attached_ppwsz_trigger: ppwsz_trigger /= Void
		deferred

		ensure
			valid_ppwsz_trigger: ppwsz_trigger.item /= Void
		end

	get_run_times (pst_begin: X_SYSTEMTIME_RECORD; pst_end: X_SYSTEMTIME_RECORD; p_count: INTEGER_REF; rgst_task_times: CELL [X_SYSTEMTIME_RECORD])
			-- Retrieves the work item run times for a specified time period.
			-- `pst_begin' [in].  
			-- `pst_end' [in].  
			-- `p_count' [in, out].  
			-- `rgst_task_times' [out].  
		require
			attached_pst_begin: pst_begin /= Void
			valid_pst_begin: pst_begin.item /= default_pointer
			attached_pst_end: pst_end /= Void
			valid_pst_end: pst_end.item /= default_pointer
			attached_p_count: p_count /= Void
			attached_rgst_task_times: rgst_task_times /= Void
		deferred

		ensure
			valid_rgst_task_times: rgst_task_times.item /= Void
		end

	get_next_run_time (pst_next_run: X_SYSTEMTIME_RECORD)
			-- Retrieves the next time the work item will run.
			-- `pst_next_run' [in, out].  
		require
			attached_pst_next_run: pst_next_run /= Void
			valid_pst_next_run: pst_next_run.item /= default_pointer
		deferred

		end

	set_idle_wait (w_idle_minutes: INTEGER; w_deadline_minutes: INTEGER)
			-- Sets the idle wait time for the work item.
			-- `w_idle_minutes' [in].  
			-- `w_deadline_minutes' [in].  
		deferred

		end

	get_idle_wait (pw_idle_minutes: INTEGER_REF; pw_deadline_minutes: INTEGER_REF)
			-- Retrieves the idle wait time for the work item.
			-- `pw_idle_minutes' [out].  
			-- `pw_deadline_minutes' [out].  
		require
			attached_pw_idle_minutes: pw_idle_minutes /= Void
			attached_pw_deadline_minutes: pw_deadline_minutes /= Void
		deferred

		end

	run
			-- Runs the work item.
		deferred

		end

	terminate
			-- Ends the execution of the work item.
		deferred

		end

	edit_work_item (h_parent: POINTER; dw_reserved: INTEGER)
			-- Opens the configuration properties for the work item.
			-- `h_parent' [in].  
			-- `dw_reserved' [in].  
		deferred

		end

	get_most_recent_run_time (pst_last_run: X_SYSTEMTIME_RECORD)
			-- Retrieves the most recent time the work item began running.
			-- `pst_last_run' [out].  
		require
			attached_pst_last_run: pst_last_run /= Void
			valid_pst_last_run: pst_last_run.item /= default_pointer
		deferred

		end

	get_status (phr_status: ECOM_HRESULT)
			-- Retrieves the status of the work item.
			-- `phr_status' [out].  
		require
			attached_phr_status: phr_status /= Void
		deferred

		end

	get_exit_code (pdw_exit_code: INTEGER_REF)
			-- Retrieves the work item's last exit code.
			-- `pdw_exit_code' [out].  
		require
			attached_pdw_exit_code: pdw_exit_code /= Void
		deferred

		end

	set_comment (pwsz_comment: STRING)
			-- Sets the comment for the work item.
			-- `pwsz_comment' [in].  
		deferred

		end

	get_comment (ppwsz_comment: CELL [STRING])
			-- Retrieves the comment for the work item.
			-- `ppwsz_comment' [out].  
		require
			attached_ppwsz_comment: ppwsz_comment /= Void
		deferred

		ensure
			valid_ppwsz_comment: ppwsz_comment.item /= Void
		end

	set_creator (pwsz_creator: STRING)
			-- Sets the creator of the work item.
			-- `pwsz_creator' [in].  
		deferred

		end

	get_creator (ppwsz_creator: CELL [STRING])
			-- Retrieves the creator of the work item.
			-- `ppwsz_creator' [out].  
		require
			attached_ppwsz_creator: ppwsz_creator /= Void
		deferred

		ensure
			valid_ppwsz_creator: ppwsz_creator.item /= Void
		end

	set_work_item_data (cb_data: INTEGER; rgb_data: CHARACTER_REF)
			-- Stores application-defined data associated with the work item.
			-- `cb_data' [in].  
			-- `rgb_data' [in].  
		require
			attached_rgb_data: rgb_data /= Void
		deferred

		end

	get_work_item_data (pcb_data: INTEGER_REF; prgb_data: CELL [CHARACTER_REF])
			-- Retrieves application-defined data associated with the work item.
			-- `pcb_data' [out].  
			-- `prgb_data' [out].  
		require
			attached_pcb_data: pcb_data /= Void
			attached_prgb_data: prgb_data /= Void
		deferred

		ensure
			valid_prgb_data: prgb_data.item /= Void
		end

	set_error_retry_count (w_retry_count: INTEGER)
			-- Not currently implemented.
			-- `w_retry_count' [in].  
		deferred

		end

	get_error_retry_count (pw_retry_count: INTEGER_REF)
			-- Not currently implemented.
			-- `pw_retry_count' [out].  
		require
			attached_pw_retry_count: pw_retry_count /= Void
		deferred

		end

	set_error_retry_interval (w_retry_interval: INTEGER)
			-- Not currently implemented.
			-- `w_retry_interval' [in].  
		deferred

		end

	get_error_retry_interval (pw_retry_interval: INTEGER_REF)
			-- Not currently implemented.
			-- `pw_retry_interval' [out].  
		require
			attached_pw_retry_interval: pw_retry_interval /= Void
		deferred

		end

	set_flags (dw_flags: INTEGER)
			-- Sets the flags that modify the behavior of the work item.
			-- `dw_flags' [in].  
		deferred

		end

	get_flags (pdw_flags: INTEGER_REF)
			-- Retrieves the flags that modify the behavior of the work item.
			-- `pdw_flags' [out].  
		require
			attached_pdw_flags: pdw_flags /= Void
		deferred

		end

	set_account_information (pwsz_account_name: STRING; pwsz_password: STRING)
			-- Sets the account name and password for the work item.
			-- `pwsz_account_name' [in].  
			-- `pwsz_password' [in].  
		deferred

		end

	get_account_information (ppwsz_account_name: CELL [STRING])
			-- Retrieves the account name for the work item.
			-- `ppwsz_account_name' [out].  
		require
			attached_ppwsz_account_name: ppwsz_account_name /= Void
		deferred

		ensure
			valid_ppwsz_account_name: ppwsz_account_name.item /= Void
		end

end -- ISCHEDULED_WORK_ITEM_INTERFACE


