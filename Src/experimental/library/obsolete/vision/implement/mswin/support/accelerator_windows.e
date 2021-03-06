note
	description: ""
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	ACCELERATORS_WINDOWS

inherit
	WEL_ACCELERATORS

create
	make

feature {NONE} -- Initialization

	make
			-- Create a accelerator table.
		do
			create accelerator_list.make
		end

feature -- Status report

	is_empty: BOOLEAN
			-- Is the `accelerator_list' empty?
		do
			Result := accelerator_list.is_empty
		end

feature -- Status setting

	add (acc: WEL_ACCELERATOR)
			-- Add an accelerator to the table
		require
			acc_not_void: acc /= Void
			acc_exists: acc.exists
		do
			if not accelerator_list.has (acc) then
				accelerator_list.extend (acc)
			end
			recreate_accelerators
		end

feature -- Removal

	remove (acc: WEL_ACCELERATOR)
			-- Remove an accelerator from the table.
		require
			acc_not_void: acc /= Void
			acc_exists: acc.exists
		do
			from
				accelerator_list.start
			until
				accelerator_list.after
			loop
				if accelerator_list.item.command_id = acc.command_id then
					accelerator_list.remove
					accelerator_list.finish
				else
					accelerator_list.forth
				end
			end
			recreate_accelerators
		end

feature {NONE} -- Implementation

	recreate_accelerators
			-- Recreate the accelerators
		require
			accelerator_list_not_void: accelerator_list /= Void
			accelerator_list_not_empty: not accelerator_list.is_empty
		local
			index: INTEGER
		do
			create acc_array.make (accelerator_list.count, accelerator_list.first.structure_size)
			from
				index := 0
				accelerator_list.start
			until
				accelerator_list.after
			loop
				acc_array.put (accelerator_list.item, index)
				index := index + 1
				accelerator_list.forth
			end
			if item /= default_pointer then
				cwin_destroy_accelerator_table (item)
			end
			item := cwin_create_accelerator_table (acc_array.item, acc_array.count)
		ensure
			exists: exists
		end

feature {NONE} -- Implementation

	accelerator_list: LINKED_LIST [WEL_ACCELERATOR]
			-- List to hold the accelerators.

	acc_array: WEL_ARRAY [WEL_ACCELERATOR];
			-- Array used to create and recreate the accelerators.

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




end -- class ACCELERATOR_WINDOWS

