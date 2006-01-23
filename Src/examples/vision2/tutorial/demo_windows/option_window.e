indexing
	description:
		"The demo that goes with the button demo"
	legal: "See notice at end of class."
	status: "See notice at end of class.";
	date: "$Date$";
	revision: "$Revision$"

class
	OPTION_WINDOW

inherit
	DEMO_WINDOW

	EV_OPTION_BUTTON
		redefine
			make
		end
	DEMO_WINDOW
	WIDGET_COMMANDS
	BUTTON_COMMANDS

create
	make

feature {NONE} -- Initialization

	make (par: EV_CONTAINER) is
			-- Create the demo in `par'.
		do
			Precursor {EV_OPTION_BUTTON} (par)
			set_vertical_resize (False)
			set_horizontal_resize (False)

			create menu.make_with_text (Current, "Menu")
			create menu_item.make_with_text (menu, "Item 1")
			create menu_item.make_with_text (menu, "Item 2")
			menu_item.set_insensitive (True)
			create menu_item.make_with_text (menu, "Item 3")
			create menu2.make_with_text (menu, "Menu 2")
			create menu_item.make_with_text (menu2, "Item 1")
			create menu_item.make_with_text (menu2, "Item 2")
			create menu_item.make_with_text (menu2, "Item 3")
			create event_window.make (Current)
			add_widget_commands (Current, event_window, "option window")
			add_button_commands (Current, event_window, "Option window")
			set_parent(par)
		end

	set_tabs is
			-- Set the tabs for the action window.
		do
			set_primitive_tabs
			tab_list.extend(textable_tab)
			tab_list.extend(fontable_tab)
			tab_list.extend(pixmapable_tab)
			tab_list.extend(option_tab)
			create action_window.make (Current,tab_list)
		end

feature -- Access

	menu: EV_MENU
	menu2: EV_MENU_ITEM
	menu_item: EV_MENU_ITEM
	menu_item5: EV_MENU_ITEM
	check_menu_item: EV_CHECK_MENU_ITEM
	menu_item2: EV_RADIO_MENU_ITEM
	menu_item3: EV_RADIO_MENU_ITEM
	menu_item4: EV_RADIO_MENU_ITEM;

indexing
	copyright:	"Copyright (c) 1984-2006, Eiffel Software and others"
	license:	"Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			 Eiffel Software
			 356 Storke Road, Goleta, CA 93117 USA
			 Telephone 805-685-1006, Fax 805-685-6869
			 Website http://www.eiffel.com
			 Customer support http://support.eiffel.com
		]"


end -- class OPTION_WINDOW

