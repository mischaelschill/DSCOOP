indexing

	description: 
		"Callback structure specific to the scroll bar. %
		%Associated C structure is XmScrollBarCallbackStruct.";
	status: "See notice at end of class.";
	date: "$Date$";
	revision: "$Revision$"

class
	MEL_SCROLL_BAR_CALLBACK_STRUCT

inherit

	MEL_ANY_CALLBACK_STRUCT
		redefine
			reasons_list
		end;

creation
	make

feature -- Access

	reasons_list: ARRAY [INTEGER] is 
			-- List of reasons that is valid for this
			-- callback structure
			-- (Reasons - XmCR_DECREMENT, XmCR_DRAG, XmCR_INCREMENT,
			-- XmCR_PAGE_INCREMENT, XmCR_PAGE_DECREMENT,
			-- XmCR_TO_BOTTOM, XmCR_TO_TOP, XmCR_VALUE_CHANGED)
		once
			Result := <<XmCR_DECREMENT, XmCR_DRAG, XmCR_INCREMENT,
				XmCR_PAGE_INCREMENT, XmCR_PAGE_DECREMENT, 
				XmCR_TO_BOTTOM, XmCR_TO_TOP, XmCR_VALUE_CHANGED>>;
		end;

	value: INTEGER is
			-- Value of the slider's new location
		do
			Result := c_value (handle)
		end;

	pixel: INTEGER is
			-- Coordinate where selection ocurred
		do
			Result := c_value (handle)
		end

feature {NONE} -- Implementation

	c_value (a_callback_struct_ptr: POINTER): INTEGER is
		external
			"C [macro %"callback_struct.h%"] (XmScrollBarCallbackStruct *): EIF_INTEGER"
		end;

	c_pixel (a_callback_struct_ptr: POINTER): INTEGER is
		external
			"C [macro %"callback_struct.h%"] (XmScrollBarCallbackStruct *): EIF_INTEGER"
		end;

end -- class MEL_SCROLL_BAR_CALLBACK_STRUCT

--|-----------------------------------------------------------------------
--| Motif Eiffel Library: library of reusable components for ISE Eiffel 3.
--| Copyright (C) 1996, Interactive Software Engineering, Inc.
--| All rights reserved. Duplication and distribution prohibited.
--|
--| 270 Storke Road, Suite 7, Goleta, CA 93117 USA
--| Telephone 805-685-1006
--| Fax 805-685-6869
--| Information e-mail <info@eiffel.com>
--| Customer support e-mail <support@eiffel.com>
--|-----------------------------------------------------------------------
