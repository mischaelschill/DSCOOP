indexing
	description:
		"Special objects: homogeneous sequences of values, %
		%used to represent arrays and strings";

	status: "See notice at end of class";
	date: "$Date$";
	revision: "$Revision$"

class
	SPECIAL [T]

feature -- Access

	item (i: INTEGER): T is
			-- Item at `i'-th position
			-- (indices begin at 0)
		require
			index_big_enough: i >= 0;
			index_small_enough: i < count
		do
			-- Built-in
		end;

feature -- Measurement

	count: INTEGER is
			-- Count of the special area
		do
			Result := sp_count ($Current);
		end;

feature -- Element change

	put (v: T; i: INTEGER) is
			-- Replace `i'-th item by `v'.
			-- (Indices begin at 0.)
		require
			index_big_enough: i >= 0;
			index_small_enough: i < count
		do
			-- Built-in
		end;

feature -- Removal

	clear_all is
			-- Reset all items to default values.
		do
			spclearall ($Current)
		end

feature {NONE} -- Implementation

	sp_count (sp_obj: POINTER): INTEGER is
			-- Count of the special object
		external
			"C | %"eif_plug.h%""
		end;

	spclearall (p: POINTER) is
			-- Reset all items to default value.
		external
			"C | %"eif_copy.h%""
		end

end -- class SPECIAL

--|----------------------------------------------------------------
--| EiffelBase: Library of reusable components for Eiffel.
--| Copyright (C) 1986-1998 Interactive Software Engineering (ISE).
--| For ISE customers the original versions are an ISE product
--| covered by the ISE Eiffel license and support agreements.
--| EiffelBase may now be used by anyone as FREE SOFTWARE to
--| develop any product, public-domain or commercial, without
--| payment to ISE, under the terms of the ISE Free Eiffel Library
--| License (IFELL) at http://eiffel.com/products/base/license.html.
--|
--| Interactive Software Engineering Inc.
--| ISE Building, 2nd floor
--| 270 Storke Road, Goleta, CA 93117 USA
--| Telephone 805-685-1006, Fax 805-685-6869
--| Electronic mail <info@eiffel.com>
--| Customer support e-mail <support@eiffel.com>
--| For latest info see award-winning pages: http://eiffel.com
--|----------------------------------------------------------------

