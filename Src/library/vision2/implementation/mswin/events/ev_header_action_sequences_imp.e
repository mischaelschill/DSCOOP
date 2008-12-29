note
	description:
		"Action sequences for EV_HEADER_IMP."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$date"
	revision: "$revision"

deferred class
	 EV_HEADER_ACTION_SEQUENCES_IMP

inherit
	EV_HEADER_ACTION_SEQUENCES_I
	
feature {NONE} -- Implementation
	
	create_item_resize_actions: EV_HEADER_ITEM_ACTION_SEQUENCE
			-- Create an item resize actions.
		do
			create Result
		end
		
	create_item_resize_start_actions: EV_HEADER_ITEM_ACTION_SEQUENCE
			-- Create an item resize start actions.
		do
			create Result
		end
		
	create_item_resize_end_actions: EV_HEADER_ITEM_ACTION_SEQUENCE
			-- Create an item resize end actions.
		do
			create Result
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




end

