indexing

	description:
		"An unix socket.";

	status: "See notice at end of class";
	date: "$Date$";
	revision: "$Revision$"

deferred class

	UNIX_SOCKET

inherit

	SOCKET
		undefine
			send, put_character, putchar, put_string, putstring,
			put_integer, putint, put_boolean, putbool,
			put_real, putreal, put_double, putdouble
		redefine
			address, cleanup, name
		end

feature -- Status Report

	address: UNIX_SOCKET_ADDRESS;
			-- Local address of socket

	cleanup is
			-- Close socket and unlink it from file system.
		do
			close;
			if address /= Void then
				unlink
			end
		end;

	name: STRING is
			-- Socket name
		require else
			valid_address: address /= Void
		do
			create Result.make (10);
			Result.append (address.path)
		end

feature -- Status setting

	unlink is
			-- Remove associate name from file system.
		require else
			name_address: address /= void
		local
			ext: C_STRING
		do
			create ext.make (name)
			c_unlink (ext.item)
		end

feature {NONE} -- Externals

	c_unlink (nam: POINTER) is
			-- External c routine to remove socket file from file
			-- system
		external
			"C"
		end

end -- class UNIX_SOCKET




--|----------------------------------------------------------------
--| EiffelNet: library of reusable components for ISE Eiffel.
--| Copyright (C) 1986-2001 Interactive Software Engineering Inc.
--| All rights reserved. Duplication and distribution prohibited.
--| May be used only with ISE Eiffel, under terms of user license. 
--| Contact ISE for any other use.
--|
--| Interactive Software Engineering Inc.
--| ISE Building
--| 360 Storke Road, Goleta, CA 93117 USA
--| Telephone 805-685-1006, Fax 805-685-6869
--| Electronic mail <info@eiffel.com>
--| Customer support: http://support.eiffel.com>
--| For latest info see award-winning pages: http://www.eiffel.com
--|----------------------------------------------------------------

