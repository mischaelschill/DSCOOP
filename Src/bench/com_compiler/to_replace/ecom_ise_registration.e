indexing
	description: "Objectes of this class set the registry keys necessary for COM to access the component%
				   %and activate a new instance of the component whenever COM asks for if.%
				   %User may inherit from this class and redifine `main_window'."
	Note: "Automatically generated by the EiffelCOM Wizard."

class
	ECOM_ISE_REGISTRATION

inherit
	ARGUMENTS

	WEL_APPLICATION
		rename
			make as wel_make
		redefine
			default_show_command
		end

	WEL_SW_CONSTANTS
		export
			{NONE} all
		end

creation
	make,
	make_test

feature {NONE}  -- Initialization

	make is
			-- Initialize server.
		local
			local_string: STRING
		do
			default_show_cmd := Sw_shownormal
			if argument_count > 0 then
				local_string :=argument (1)
				local_string.to_lower
			end
			if local_string /= Void and (local_string.is_equal ("-regserver") or local_string.is_equal ("/regserver")) then
				register_server
			elseif local_string /= Void and (local_string.is_equal ("-unregserver") or local_string.is_equal ("/unregserver")) then
				unregister_server
			else
				if local_string /= Void and (local_string.is_equal ("-embedding") or local_string.is_equal ("/embedding")) then
					default_show_cmd := Sw_hide
				end
				initialize_com
				wel_make
				cleanup_com
			end
		end
	
	make_test is
			-- creates test version of compiler
		do
			--| Please add implementation as appropriate
		end
		
feature -- Access

	main_window: MAIN_WINDOW is
			-- Server main window
		once
			create Result.make_top ("Should not see me!")
		end

	default_show_command: INTEGER is
			-- Default command used to show `main_window'.
		once
			Result := default_show_cmd
		end

feature {NONE}  -- Implementation

	default_show_cmd: INTEGER
			-- Default command used to show `main_window'.

	initialize_com is
			-- Initialize COM 
		do
			ccom_initialize_com
		end

	cleanup_com is
			-- Clean up COM 
		do
			ccom_cleanup_com
		end

	register_server is
			-- Register Server
		do
			ccom_register_server
		end

	unregister_server is
			-- Unregister Server
		do
			ccom_unregister_server
		end

feature {NONE}  -- Externals

	ccom_initialize_com is
			-- Initialize COM.
		external
			"C++[macro %"server_registration.h%"]"
		end

	ccom_cleanup_com is
			-- Clean up COM.
		external
			"C++[macro %"server_registration.h%"]"
		end

	ccom_register_server is
			-- Register server.
		external
			"C++[macro %"server_registration.h%"]"
		end

	ccom_unregister_server is
			-- Unregister server.
		external
			"C++[macro %"server_registration.h%"]"
		end

end -- ECOM_ISE_REGISTRATION
