note
	description: "Summary description for {MESSAGING}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MESSAGING

inherit
	CLI_COMMAND

feature
	name: ESTRING_8
		once
			Result := "messaging"
		end

	call (a_arguments: LIST[ESTRING_8])
		do
			if a_arguments.count > 0 then
				if a_arguments[1] ~ "server" then
					if
						a_arguments.count = 2 and then
						attached a_arguments[2].to_natural_16 as port
					then
						run_server (port)
					else
						print_usage
					end
				elseif a_arguments[1] ~ "test" then
					if
						a_arguments.count = 6 and then
						attached a_arguments[2].to_natural_16 as port and then
						attached a_arguments[3] as server_address and then
						attached a_arguments[4].to_natural_16 as server_port and then
						attached a_arguments[5] as client_name and then
						attached a_arguments[6] as recipient
					then
						run_test (port, server_address, server_port, client_name, recipient)
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
			print ("Usage: chat test <port> <server address> <server port> <name> <recipient> or%N")
			print ("       chat server <port>%N")
		end

feature
	run_test (a_port: NATURAL_16; a_server_address: ESTRING_8; a_server_port: NATURAL_16; a_name, a_recipient: ESTRING_8)
			-- Runs the messaging test client
		local
			dscoop: DSCOOP
			l_client: separate MESSAGING_CLIENT
			l_message: ESTRING_8
		do
			create dscoop
			l_message := "TEST"
			separate dscoop.server as c_server do
				-- Start the server
				c_server.start_incoming (a_port)
			end

			check attached get_server(a_server_address, a_server_port) as l_server then
				create l_client.make (a_name, l_server)
				separate l_client as c_client do
					c_client.send_message (a_recipient, l_message)
				end
				wait_for_message (l_client, l_message)
			end
		end

	wait_for_message (a_client: separate MESSAGING_CLIENT; a_message: ESTRING_8)
		require
			a_client.messages.has(a_message)
		do
			print ("Success%N")
		end

	run_server (a_port: NATURAL_16)
		local
			dscoop: DSCOOP
		do
			-- Create a DSCOOP server
			create dscoop
			separate dscoop.server as c_server do
				-- Export the fork as the index object
				c_server.set_index_object (create {separate MESSAGING_SERVER}.make)
				-- Start the server
				c_server.start_incoming (a_port)
			end
		end

feature {NONE} -- Implementation
	get_server (a_supplier_address: ESTRING_8; a_supplier_port: NATURAL_16): detachable separate MESSAGING_SERVER
		local
			l_connection: DSCOOP_CONNECTION
		do
			create l_connection.make
			l_connection.connect (a_supplier_address, a_supplier_port)
			-- Checking that the connection is established
			if
				l_connection.is_initialized and then
				attached {separate MESSAGING_SERVER} l_connection.get_remote_index as supplier
			then
				Result := supplier
			else
				io.error.put_string ("Couldn't get index from " + a_supplier_address.out + ":" + a_supplier_port.out + "%N")

			end
		end
end
