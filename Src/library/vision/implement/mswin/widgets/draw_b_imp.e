indexing
	description: "This class represents a MS_IMPdraw button"
	status: "See notice at end of class"
	date: "$Date$"
	revision: "$Revision$"

class
	DRAW_B_IMP

inherit
	DRAW_B_I
			
	OWNER_DRAW_BUTTON_WINDOWS

	DRAWABLE_DEVICE_WINDOWS

create 
	make

feature -- Initialization

	make (a_draw_b: DRAW_B; man: BOOLEAN; oui_parent: COMPOSITE) is
		do
			create private_attributes
			a_draw_b.set_font_imp (Current)
			parent ?= oui_parent.implementation;
			set_line_width (1);
			managed := man
			create gc_fg_color.make_system (color_windowtext)
			line_style := ps_solid
		end

feature -- Status setting

	draw_selected (a_dc: WEL_DC) is
			-- Do actions
		do
			set_drawing_dc (a_dc)
			expose_actions.execute (Current, Void)
			unset_drawing_dc
		end

	draw_unselected (a_dc: WEL_DC) is
			-- Do actions
		do
			set_drawing_dc (a_dc)
			expose_actions.execute (Current, Void)
			unset_drawing_dc
		end

end -- class DRAW_B_IMP

--|----------------------------------------------------------------
--| EiffelVision: library of reusable components for ISE Eiffel.
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

