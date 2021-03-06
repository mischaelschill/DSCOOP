note
	description: "implementation for DEBUGGER_MANAGER"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	TTY_DEBUGGER_EVENTS_HANDLER_IMP

create {TTY_DEBUGGER_EVENTS_HANDLER}
	make

feature {NONE} -- Initialization

	make (a_interface: like interface)
			-- Initialize current
		do
			interface := a_interface
		end

feature {DEBUGGER_EVENTS_HANDLER} -- Access

	process_underlying_toolkit_event_queue
		local
			l_no_more_events: BOOLEAN
		do
			from
			until
				l_no_more_events
			loop
				dispatch_events
				l_no_more_events := not events_pending
			end
		end

	timer_win32_handle: POINTER
		do
		end

	frozen dispatch_events
		external
			"C inline use <gtk/gtk.h>"
		alias
			"g_main_context_dispatch(g_main_context_default())"
		end

	frozen events_pending: BOOLEAN
		external
			"C inline use <gtk/gtk.h>"
		alias
			"g_main_context_pending (g_main_context_default())"
		end

feature {NONE} -- Interface

	interface: TTY_DEBUGGER_EVENTS_HANDLER;
			-- Interface instance.

note
	copyright:	"Copyright (c) 1984-2006, Eiffel Software"
	license:	"GPL version 2 (see http://www.eiffel.com/licensing/gpl.txt)"
	licensing_options:	"http://www.eiffel.com/licensing"
	copying: "[
			This file is part of Eiffel Software's Eiffel Development Environment.
			
			Eiffel Software's Eiffel Development Environment is free
			software; you can redistribute it and/or modify it under
			the terms of the GNU General Public License as published
			by the Free Software Foundation, version 2 of the License
			(available at the URL listed under "license" above).
			
			Eiffel Software's Eiffel Development Environment is
			distributed in the hope that it will be useful,	but
			WITHOUT ANY WARRANTY; without even the implied warranty
			of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
			See the	GNU General Public License for more details.
			
			You should have received a copy of the GNU General Public
			License along with Eiffel Software's Eiffel Development
			Environment; if not, write to the Free Software Foundation,
			Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA
		]"
	source: "[
			 Eiffel Software
			 356 Storke Road, Goleta, CA 93117 USA
			 Telephone 805-685-1006, Fax 805-685-6869
			 Website http://www.eiffel.com
			 Customer support http://support.eiffel.com
		]"

end
