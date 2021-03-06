note
	description:
		"Action sequences for EV_WINDOW."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	keywords: "event, action, sequence"
	date: "Generated!"
	revision: "Generated!"

deferred class
	 EV_WINDOW_ACTION_SEQUENCES

inherit
	EV_ACTION_SEQUENCES

feature {NONE} -- Implementation

	implementation: EV_WINDOW_ACTION_SEQUENCES_I
		deferred
		end

feature -- Event handling


	move_actions: EV_GEOMETRY_ACTION_SEQUENCE
			-- Actions to be performed when window moves.
		do
			Result := implementation.move_actions
		ensure
			not_void: Result /= Void
		end


	show_actions: EV_NOTIFY_ACTION_SEQUENCE
			-- Actions to be performed when window is shown.
		do
			Result := implementation.show_actions
		ensure
			not_void: Result /= Void
		end

	hide_actions: EV_NOTIFY_ACTION_SEQUENCE
			-- Actions to be performed when window is hidden.
		do
			Result := implementation.hide_actions
		ensure
			not_void: Result /= Void
		end

	close_request_actions: EV_NOTIFY_ACTION_SEQUENCE
			-- Actions to be performed whan a request to close window
			-- has been received.
		do
			Result := implementation.close_request_actions
		ensure
			not_void: Result /= Void
		end

note
	copyright:	"Copyright (c) 1984-2014, Eiffel Software and others"
	license:	"Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"




end

