indexing
	description: "Action sequence for docking events."
	status: "See notice at end of class"
	date: "$Date$"
	revision: "$Revision$"

class
	EV_DOCKABLE_SOURCE_ACTION_SEQUENCE
inherit
	EV_ACTION_SEQUENCE [TUPLE [EV_DOCKABLE_SOURCE]]
	-- EV_ACTION_SEQUENCE [TUPLE [source: EV_DOCKABLE_SOURCE]]
	-- (ETL3 TUPLE with named parameters)
	
create
	default_create

feature -- Access

	force_extend (action: PROCEDURE [ANY, TUPLE]) is
			-- Extend without type checking.
		do
			extend (agent wrapper (?, action))
		end

	wrapper (source: EV_DOCKABLE_SOURCE; action: PROCEDURE [ANY, TUPLE]) is
			-- Use this to circumvent tuple type checking. (at your own risk!)
			-- Calls `action' passing all other arguments.
		do
			action.call ([source])
		end

end -- class EV_DOCKABLE_SOURCE_ACTION_SEQUENCE

--|----------------------------------------------------------------
--| EiffelVision2: library of reusable components for ISE Eiffel.
--| Copyright (C) 1985-2004 Eiffel Software. All rights reserved.
--| Duplication and distribution prohibited.  May be used only with
--| ISE Eiffel, under terms of user license.
--| Contact Eiffel Software for any other use.
--|
--| Interactive Software Engineering Inc.
--| dba Eiffel Software
--| 356 Storke Road, Goleta, CA 93117 USA
--| Telephone 805-685-1006, Fax 805-685-6869
--| Contact us at: http://www.eiffel.com/general/email.html
--| Customer support: http://support.eiffel.com
--| For latest info on our award winning products, visit:
--|	http://www.eiffel.com
--|----------------------------------------------------------------

