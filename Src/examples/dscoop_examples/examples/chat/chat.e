note
	description: "Summary description for {CHAT}."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	CHAT

inherit
	CLI_COMMAND

feature
	name: ESTRING_8
		once
			Result := "chat"
		end

	call (a_arguments: LIST[ESTRING_8])
		do
			if a_arguments.count > 0 then
				if a_arguments[1] ~ "client" then
					if
						a_arguments.count = 3 and then
						attached a_arguments[2] as address and then
						attached a_arguments[3].to_natural_16 as port
					then
						run_client (address, port)
					else
						print_usage
					end
				elseif a_arguments[1] ~ "server" then
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
						a_arguments.count = 3 and then
						attached a_arguments[2].to_integer as user and then
						attached a_arguments[3].to_integer as total
					then
						run_test (user, total)
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
			print ("Usage: chat client <address> <port> or%N")
			print ("       chat server <port>%N")
		end

feature
	run_client (a_address: ESTRING_8; a_port: NATURAL_16)
			-- Runs the chat client
		local
			l_name: ESTRING_8
			l_chat_client: CHAT_CLIENT
		do
			io.put_string ("Hello, what is your name?%N")
			io.read_line
			l_name := io.last_string
			create l_chat_client
			l_chat_client.start (a_address, a_port, "lobby", l_name)
		end

	run_server (a_port: NATURAL_16)
		local
			sei: SEI
		do
			-- Create a SEI server
			create sei
			separate sei.server as c_server do
				-- Export the fork as the index object
				c_server.set_index_object (create {separate CHAT_SERVER})
				-- Start the server
				c_server.start_incoming (a_port)
			end
		end

	run_test (a_user, a_total: INTEGER)
		-- Starts the chat client
		local
			l_chat_client: CHAT_CLIENT
		do
			create l_chat_client
			l_chat_client.test ("127.0.0.1", "lobby", a_user, a_total)
		end
end
