indexing

	description: "Command to popdown a shell";
	status: "See notice at end of class";
	date: "$Date$";
	revision: "$Revision$"

class

	POPDOWN_COM 

inherit

	COMMAND

feature -- Basic operations

	execute (argument: ANY) is
			-- Popdown a shell.
		local
			shell: POPUP_SHELL;
			dialog: DIALOG
		do
			shell ?= argument;
			if (shell = Void) then
				dialog ?= argument;
				dialog.popdown;
			else
				shell.popdown;
			end
		end

end -- class POPDOWN_COM


--|----------------------------------------------------------------
--| EiffelVision: library of reusable components for ISE Eiffel.
--| Copyright (C) 1986-1997 Interactive Software Engineering Inc.
--| All rights reserved. Duplication and distribution prohibited.
--| May be used only with ISE Eiffel, under terms of user license. 
--| Contact ISE for any other use.
--|
--| Interactive Software Engineering Inc.
--| 270 Storke Road, Suite 7, Goleta, CA 93117 USA
--| Telephone 805-685-1006, Fax 805-685-6869
--| Electronic mail <info@eiffel.com>
--| Customer support e-mail <support@eiffel.com>
--| For latest info see award-winning pages: http://www.eiffel.com
--|----------------------------------------------------------------
