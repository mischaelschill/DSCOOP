indexing
	description:
		"Eiffel Vision popup menu handler. Invisible window that lets%N%
		%`menu_item_list' receive click commands."
	status: "See notice at end of class"
	date: "$Date$"
	revision: "$Revision$"
	
class
	EV_POPUP_MENU_HANDLER

inherit
	WEL_FRAME_WINDOW
		undefine
			on_draw_item
		redefine
			on_menu_command,
			default_process_message,
			class_requires_icon
		end
		
	EV_MENU_CONTAINER_IMP
		export
			{NONE} all
		end

create
	make_with_menu

feature {NONE} -- Initialization

	make_with_menu (a_menu: EV_MENU_ITEM_LIST_IMP) is
			-- Initialize with `a_menu'.
		require
			a_menu_not_void: a_menu /= Void
		do
			make_top ("EV_POPUP_MENU_HANDLER")
			menu_item_list := a_menu
			set_menu (menu_item_list)
		end

feature {NONE} -- Implementation

	menu_item_list: EV_MENU_ITEM_LIST_IMP
			-- Connected menu.

	on_menu_command (an_id: INTEGER) is
			-- Propagate to `menu'.
		do
			menu_item_list.menu_item_clicked (an_id)
		end

	default_process_message (msg, wparam, lparam: INTEGER) is
			-- Process `msg' which has not been processed by
			-- `process_message'.
		do
			if not process_menu_message(msg, wparam, lparam) then
				Precursor (msg, wparam, lparam)
			end
		end

feature {NONE} -- WEL Implementation

	on_menu_char (char_code: CHARACTER; corresponding_menu: WEL_MENU) is
			-- The menu char `char_code' has been typed within `corresponding_menu'.
		local
			return_value: INTEGER
		do
			return_value := menu_item_list.on_menu_char (char_code, corresponding_menu)
			set_message_return_value (return_value)
		end
		
	class_requires_icon: BOOLEAN is
			-- Does `Current' require an icon to be registered?
			-- If `True' `register_class' assigns a class icon, otherwise
			-- no icon is assigned.
		do
			Result := False
		end

end -- class EV_POPUP_MENU_HANDLER

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

