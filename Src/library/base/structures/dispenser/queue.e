indexing

	description:
		"Queues (first-in, first-out dispensers), without commitment %
		%to a particular representation";

	status: "See notice at end of class";
	names: queue, dispenser;
	access: fixed, fifo, membership;
	contents: generic;
	date: "$Date$";
	revision: "$Revision$"

deferred class QUEUE [G] inherit

	DISPENSER [G]
		export
			{NONE} prune, prune_all
		end

feature -- Element change

	 force (v: like item) is
			-- Add `v' as newest item.
		deferred
		end;

end -- class QUEUE


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

