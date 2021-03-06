note

	description: 
		"EiffelVision implementation of a Motif pulldown for menu buttons."
	legal: "See notice at end of class.";
	status: "See notice at end of class.";
	date: "$Date$";
	revision: "$Revision$"

class 
	MENU_PULL_IMP

inherit

	MENU_PULL_I;

	MENU_IMP
		rename
			set_foreground_color as menu_set_foreground_color,
			set_background_color as menu_set_background_color,
			set_size as menu_set_size,
			set_width as menu_set_width,
			set_height as menu_set_height,
            is_shown as shown
		undefine
			create_callback_struct
		redefine
			set_x_y, 
			real_x, real_y, 
			x, y, set_x, set_y, height, width,
			managed, set_managed, parent
		end;

	MENU_IMP
        rename
            is_shown as shown
		undefine
			create_callback_struct
		redefine
			set_x_y, set_size, set_width, set_height, 
			real_x, real_y, x, y,
			set_x, set_y, height, width, managed, set_managed,
			set_foreground_color, set_background_color, parent
		select
			set_size, set_width, set_height, 
			set_foreground_color, set_background_color
		end;

	MEL_PULLDOWN_MENU
		rename
			make as mel_make_menu_pull,
			foreground_color as mel_foreground_color,
			set_foreground_color as mel_set_foreground_color,
			background_color as mel_background_color,
			background_pixmap as mel_background_pixmap,
			set_background_color as mel_set_background_color,
			set_background_pixmap as mel_set_background_pixmap,
			destroy as mel_destroy,
			set_insensitive as mel_set_insensitive,
			screen as mel_screen,
            is_shown as shown
		redefine
			set_size, set_width, set_height, 
			set_x, set_x_y, set_y, real_x, real_y,
			x, y, height, width, parent
		end

create

	make

feature {NONE} -- Initialization

	make (a_pulldown: MENU_PULL; man: BOOLEAN; oui_parent: MENU)
			-- Create a motif pulldown menu.
		local
			pulldown_identifier: STRING;
			mel_c: MEL_CASCADE_BUTTON;
		do
				-- The widget index is incremented by one since
				-- the option_button will be inserted before Current
				-- in the widget_manager.
			widget_index := widget_manager.last_inserted_position + 1;
			pulldown_identifier := clone (a_pulldown.identifier);
			pulldown_identifier.append ("_pull");
			if man then
				create menu_button.make (a_pulldown.identifier, oui_parent);
			else
				create menu_button.make_unmanaged (a_pulldown.identifier, oui_parent);
			end;
			mel_c ?= menu_button.implementation;
			mel_make_menu_pull (pulldown_identifier, mel_c.parent);
			mel_c.set_sub_menu (Current);
			abstract_menu := a_pulldown
		end;

feature -- Access

	parent: MEL_MENU_SHELL
			-- Parent of pulldown

	text: STRING
			-- Label of option button
		do
			Result := menu_button.text
		end;

	managed: BOOLEAN
			-- Is the menu_button managed?
		do
			Result := menu_button.managed;
		end;

	height: INTEGER
			-- Height of button
		do
			Result := menu_button.height;
		end;

	width: INTEGER
			-- Width of button
		do
			Result := menu_button.width;
		end;

	real_x: INTEGER
			-- Relative x position of button
		do
			Result := widget_oui.parent.real_x + x
		end;

	real_y: INTEGER
			-- Relative y position of button
		do
			Result := widget_oui.parent.real_y + y
		end;

	x: INTEGER
			-- Button x position
		do
			Result := menu_button.x;
		end;

	y: INTEGER
			-- Button y position
		do
			Result := menu_button.y;
		end;

feature -- Status setting

	set_text (a_text: STRING)
			-- Set button text to `a_text'.
		do
			menu_button.set_text (a_text)
		end;

	set_managed (flag: BOOLEAN)
			-- Set `managed' to `flag'.
		do
			menu_button.set_managed (flag);
		end;

	set_x (new_x: INTEGER)
			-- Set `x' to `new_x'.
		do
			menu_button.set_x (new_x);
		end;

	set_y (new_y: INTEGER)
			-- Set `y' to `new_y'.
		do
			menu_button.set_y (new_y);
		end;


	set_x_y (new_x, new_y: INTEGER)
		do
			menu_button.set_x_y (new_x, new_y);
		end;

	set_size (new_width, new_height: INTEGER)
			-- Set size to `new_width' and `new_height'.
		do
			menu_button.set_size (new_width, new_height);
		end;

	set_width (new_width: INTEGER)
			-- Set `width' to `new_width'.
		do
			menu_button.set_width (new_width);
		end;

	set_height (new_height: INTEGER)
			-- Set `height' to `new_height'.
		do
			menu_button.set_height (new_height);
		end;

	set_foreground_color (a_color: COLOR)
			-- Set `foreground_color' to `a_color'.
		do
			menu_button.set_foreground_color (a_color);
			menu_set_foreground_color (a_color);
		end;

	set_background_color (a_color: COLOR)
		do
			menu_button.set_background_color (a_color);
			menu_set_background_color (a_color);
		end;

	allow_recompute_size
			-- Allow recompute size for button.
		do
			menu_button.allow_recompute_size;
		end;

	forbid_recompute_size
			-- Disable recompute size for button.
		do
			menu_button.forbid_recompute_size;
		end;

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




end -- class MENU_PULL_IMP

