indexing 
	description:
		"Interactive horizontal range widget. A sliding thumb displays the%N%
		%current `value' and allows it to be adjusted"
	appearance:
		"+-------------+%N%
		%|  |#|        |%N%
		%+-------------+"
	status: "See notice at end of class"
	keywords: "range, slide, adjust"
	date: "$Date$"
	revision: "$Revision$"

class
	EV_HORIZONTAL_RANGE

inherit
	EV_RANGE
		redefine
			implementation
		end

create
	default_create,
	make_with_value_range

feature {EV_ANY_I} -- Implementation

	implementation: EV_HORIZONTAL_RANGE_I
			-- Platform dependent access.
			
feature {NONE} -- Implementation

	create_implementation is
			-- Create implementation of horizontal range.
		do
			create {EV_HORIZONTAL_RANGE_IMP} implementation.make (Current)
		end

end -- class EV_HORIZONTAL_RANGE

--!-----------------------------------------------------------------------------
--! EiffelVision2: library of reusable components for ISE Eiffel.
--! Copyright (C) 1986-2000 Interactive Software Engineering Inc.
--! All rights reserved. Duplication and distribution prohibited.
--! May be used only with ISE Eiffel, under terms of user license. 
--! Contact ISE for any other use.
--!
--! Interactive Software Engineering Inc.
--! ISE Building, 2nd floor
--! 270 Storke Road, Goleta, CA 93117 USA
--! Telephone 805-685-1006, Fax 805-685-6869
--! Electronic mail <info@eiffel.com>
--! Customer support e-mail <support@eiffel.com>
--! For latest info see award-winning pages: http://www.eiffel.com
--!-----------------------------------------------------------------------------
