indexing

	description: 
		"Status information about the running application - current routine,%
		%current object, ..."
	date: "$Date$"
	revision: "$Revision $"

deferred class APPLICATION_STATUS

inherit
	ANY

	SHARED_DEBUG
		export
			{NONE} all
		end
	SHARED_EIFFEL_PROJECT
		export
			{NONE} all
		end
	IPC_SHARED
		export
			{NONE} all
			{ANY} Pg_break, Pg_interrupt,
				Pg_raise, Pg_viol 
		end
	SHARED_APPLICATION_EXECUTION
		export
			{NONE} all
		end

--creation {APPLICATION_STATUS_EXPORTER}
--
--	do_nothing

feature {NONE} -- Initialization

	initialize is
			-- Initialize Current
		do
			create call_stack_list.make (5)
		end

feature -- Callstack

	reload_current_call_stack is
			-- reload the call stack from application (after having edited an
			-- object for example to make sure the modification was successful).
		do
				-- re-create the call stack
			create_current_callstack_with (stack_max_depth)
		end

	create_current_callstack_with (a_stack_max_depth: INTEGER) is
		deferred
		end

feature -- Values

	is_stopped: BOOLEAN
			-- Is the debugged application stopped ?

	e_feature: E_FEATURE
			-- Feature in which we are currently stopped

	body_index: INTEGER
			-- Body index of the feature in which we are currently stopped

	dynamic_class: CLASS_C
			-- Class type of object in which we are currently
			-- stopped

	origin_class: CLASS_C
			-- Origin of feature in which we are currently
			-- stopped

	break_index: INTEGER
			-- Breakpoint at which we are currently stopped
			-- (first, second...)

	reason: INTEGER
			-- Reason for the applicaiton being stopped

	object_address: STRING
			-- Address of object in which we are stopped
			-- (hector address with an indirection)

	current_thread_id: INTEGER
	
	all_thread_ids: ARRAY [INTEGER]
	
	set_current_thread_id (tid: INTEGER) is
		require
			id_valid: tid > 0
		do
			current_thread_id := tid
		end
		
	set_thread_ids (a: ARRAY [INTEGER]) is
			-- 
		require
			a_not_empty: a /= Void and then not a.is_empty
		do
			all_thread_ids := a.twin
		end
		
	set_call_stack (tid: INTEGER; ecs: EIFFEL_CALL_STACK) is
		require
			id_valid: tid > 0
			callstack_not_void: ecs /= Void
		do
			call_stack_list.force (ecs, tid)
		end
		
	call_stack_list: HASH_TABLE [EIFFEL_CALL_STACK, INTEGER]

	exception_code: INTEGER
			-- Exception code if any

	exception_tag: STRING
			-- Exception tag if any

	call_stack (tid: INTEGER): EIFFEL_CALL_STACK is
		do
			Result := call_stack_list.item (tid)
		ensure
			Result /= Void implies tid > 0
		end
		
	current_call_stack: like call_stack is
		do
			Result := call_stack (current_thread_id)
		end

	current_call_stack_element: CALL_STACK_ELEMENT is
			-- Current call stack element being displayed
		do
			Result := current_call_stack.i_th (Application.current_execution_stack_number)
		end
		
	current_eiffel_call_stack_element: EIFFEL_CALL_STACK_ELEMENT is
			-- Current call stack element being displayed
		do
			Result ?= current_call_stack.i_th (Application.current_execution_stack_number)
		end
		
	stack_max_depth: INTEGER
			-- Maximum number of stack elements that we retrieve from the application.

feature -- Access

	class_name: STRING is
			-- Class name of object in which we are currently
			-- stopped
		do
			Result := dynamic_class.name
		end

	valid_reason: BOOLEAN is
			-- Is the reason valid for stopping of execution?
		do
			Result := reason = Pg_break or else
				reason = Pg_interrupt or else
				reason = Pg_raise or else
				reason = Pg_viol or else
				reason = Pg_new_breakpoint or else
				reason = Pg_step
		ensure
			true_implies_correct_reason: 
				Result implies (reason = Pg_break) or else
						(reason = Pg_interrupt) or else
						(reason = Pg_raise) or else
						(reason = Pg_viol) or else
						(reason = Pg_new_breakpoint) or else
						(reason = Pg_step)
		end

	is_at (f_body_index: INTEGER; index: INTEGER): BOOLEAN is
			-- Is the program stopped at the given index in the given feature ? 
			-- Returns False when the couple ('f','index') cannot be found on the stack.
			--         or is on the stack but not currently active.
			-- Returns True when the couple ('f','index') is active (i.e is the current
			--	       active feature on stack)
		local
			stack_elem: EIFFEL_CALL_STACK_ELEMENT
			current_execution_stack_number: INTEGER
			l_ccs: EIFFEL_CALL_STACK
		do
			if is_stopped then
				l_ccs := current_call_stack
				if l_ccs /= Void and then not l_ccs.is_empty then
					current_execution_stack_number := Application.current_execution_stack_number
					stack_elem ?= l_ccs.i_th (Application.current_execution_stack_number)
					Result := stack_elem /= Void 
							and then f_body_index = stack_elem.body_index 
							and then index = stack_elem.break_index 
				end
			end
		end

	is_top (f_body_index: INTEGER; index: INTEGER): BOOLEAN is
			-- Return True if the couple ('f','index') is the top position on the stack,
			-- Return False if the couple ('f','index') is somewhere else in the stack,
			-- 		or if the couple ('f','index') is not in the stack.
		local
			stack_elem: EIFFEL_CALL_STACK_ELEMENT
			l_ccs: EIFFEL_CALL_STACK
		do
			if is_stopped then
				l_ccs := current_call_stack
				if l_ccs /= Void and then not l_ccs.is_empty then
					stack_elem ?= l_ccs.i_th (1)
					Result := stack_elem /= Void 
							and then f_body_index = stack_elem.body_index 
							and then index = stack_elem.break_index
				end
			end
		end
		
	has_valid_call_stack: BOOLEAN is
			-- Has a valid callstack ?
		do
			if is_stopped then
				if current_call_stack /= Void and then current_call_stack.count > 0 then
					Result := True
				end
			end
		end
		
	has_valid_current_eiffel_call_stack_element: BOOLEAN is
			-- Is current call stack element a valid Eiffel Call Stack Element ?
		do
			Result := current_eiffel_call_stack_element /= Void	
		end		

feature -- Update

	update is
			-- Update data which need update after application is really stopped
		do
		end
		
feature -- Setting

	set_is_stopped (b: BOOLEAN) is
			-- set is_stopped to `b'
		do
			is_stopped := b
		end

	set_exception (i: INTEGER; s: STRING) is
		do
			exception_code := i
			exception_tag := s
		end

	set_max_depth (n: INTEGER) is
			-- Set the maximum number of stack elements that should be retrieved to `n'.
			-- -1 retrieves all elements.
		require
			valid_n: n = -1 or n > 0
		do
			stack_max_depth := n
		end

feature -- Output

	display_status (st: STRUCTURED_TEXT) is
			-- Display the status of the running application.
		local
			c, oc: CLASS_C
			cs: CALL_STACK_ELEMENT
			stack_num: INTEGER
			ccs: EIFFEL_CALL_STACK
		do
			if not is_stopped then
				st.add_string ("System is running")
				st.add_new_line
			else -- Application is stopped.
				-- Print object address.
				st.add_string ("Stopped in object [")
				c := dynamic_class
				st.add_address (object_address, e_feature.name, c)
				st.add_string ("]")
				st.add_new_line
					-- Print class name.
				st.add_indent
				st.add_string ("Class: ")
				c.append_name (st)
				st.add_new_line
					-- Print routine name.
				st.add_indent
				st.add_string ("Feature: ")
				if e_feature /= Void then
					oc := origin_class
					e_feature.append_name (st)
					if oc /= c then
						st.add_string (" (From ")
						oc.append_name (st)
						st.add_string (")")
					end
				else
					st.add_string ("Void")
				end
				st.add_new_line
					-- Print the reason for stopping.
				st.add_indent
				st.add_string ("Reason: ")
				inspect reason
				when Pg_break then
					st.add_string ("Stop point reached")
					st.add_new_line
				when Pg_interrupt then
					st.add_string ("Execution interrupted")
					st.add_new_line
				when Pg_raise then
					st.add_string ("Explicit exception pending")
					st.add_new_line
					display_exception (st)
				when Pg_viol then
					st.add_string ("Implicit exception pending")
					st.add_new_line
					display_exception (st)
				when Pg_new_breakpoint then
					st.add_string ("New breakpoint(s) to commit")
					st.add_new_line
					display_exception (st)
				when Pg_step then
					st.add_string ("Step completed")
					st.add_new_line
				else
					st.add_string ("Unknown")
					st.add_new_line
				end
				ccs := current_call_stack
				if not ccs.is_empty then
					stack_num := Application.current_execution_stack_number
					cs := ccs.i_th (stack_num)
					cs.display_arguments (st)
					cs.display_locals (st)
					ccs.display_stack (st)
				end
			end
		end
	
	display_exception (st: STRUCTURED_TEXT) is
			-- Display exception in `st'.
		require
			non_void_st: st /= Void
			valid_code: exception_code > 0
		local
			e: EXCEPTIONS
			m: STRING
		do
			st.add_indent
			st.add_indent
			st.add_string ("Code: ")
			st.add_int (exception_code)
			st.add_string (" (")
			create e
			m := e.meaning (exception_code)
			if m = Void then
				m := "Undefined"
			end
			st.add_string (m)
			st.add_string (")")
			st.add_new_line
			st.add_indent
			st.add_indent
			st.add_string ("Tag: ")
			st.add_string (exception_tag)
			st.add_new_line
		end

end -- class APPLICATION_STATUS
