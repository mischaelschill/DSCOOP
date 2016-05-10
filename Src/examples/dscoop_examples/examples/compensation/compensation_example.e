note
	description: "{COMPENSATION_EXAMPLE} is a simple example testing compensation."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	COMPENSATION_EXAMPLE

inherit
	CLI_COMMAND

feature
	name: ESTRING_8
		once
			Result := "comp"
		end

	call (a_arguments: LIST[ESTRING_8])
		do
			if a_arguments.count > 0 then
				if a_arguments[1] ~ "client" then
					if
						a_arguments.count = 3 and then
						attached a_arguments[2] as supplier_address and then
						attached a_arguments[3].to_natural_16 as supplier_port
					then
						run_client (supplier_address, supplier_port)
					else
						print_usage
					end
				elseif a_arguments[1] ~ "supplier" then
					if
						a_arguments.count = 2 and then
						attached a_arguments[2].to_natural_16 as port
					then
						run_supplier (port)
					else
						print_usage
					end
				else
					print_usage
				end
			else
				print_usage
			end
		end

feature
	print_usage
		do
			print ("Usage: comp client <address> <port> or%N")
			print ("       comp supplier <port>%N")
		end

feature
	run_supplier (a_port: NATURAL_16)
		local
			sei: SEI
		do
			enable_debug
			-- Create a SEI server
			create sei
			separate sei.server as c_server do
				-- Export the fork as the index object
				c_server.set_index_object (create {separate POLITICIAN})
				-- Start the server
				c_server.start_incoming (a_port)
			end
		end

	run_client (a_supplier_address: ESTRING_8; a_supplier_port: NATURAL_16)
		local
			retried: BOOLEAN
		do
			enable_debug
			if not retried then
				if attached get_supplier_object (a_supplier_address, a_supplier_port) as supplier then
					separate supplier as s do
						s.say_something
						if attached connection as c_connection then
							c_connection.close
						end
					end
				else
					io.error.put_string ("failed to get supplier object%N")
				end
			end
		rescue
			retried := True
			retry
		end

	connection: detachable SEI_CONNECTION

feature {NONE}

	get_supplier_object (a_supplier_address: ESTRING_8; a_supplier_port: NATURAL_16): detachable separate POLITICIAN
		local
			l_connection: SEI_CONNECTION
		do
			create l_connection.make
			l_connection.connect (a_supplier_address, a_supplier_port)
			-- Checking that the connection is established
			if
				l_connection.is_initialized and then
				attached {separate POLITICIAN} l_connection.get_remote_index as supplier
			then
				Result := supplier
				connection := l_connection
			end
		end

	enable_debug
		external
			"C inline use eif_sei.h"
		alias
			"sei_set_print_debug_messages (EIF_TRUE)"
		end
end
