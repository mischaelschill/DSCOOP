note
	description: "The {LOGGING_EXAMPLE} shows how distributed loggers can write to several logs that are kept in sync."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	LOGGING_EXAMPLE

inherit
	CLI_COMMAND

feature
	run_log_file (a_port: NATURAL_16)
		local
			dscoop: DSCOOP
		do
			-- Create a DSCOOP server
			create dscoop
			separate dscoop.server as l_server do
				-- Export the fork as the index object
				l_server.set_index_object (create {separate LOG_FILE}.make)
				-- Start the server
				l_server.start_incoming (a_port)
			end
		end

	run_logger (a_clients, a_entries: INTEGER; a_log_file_addresses: LIST[TUPLE[address: ESTRING_8; port: NATURAL_16]])
		require
			a_clients > 0
		local
			connection: DSCOOP_CONNECTION
			l_connections: ARRAYED_LIST[separate DSCOOP_CONNECTION]
			l_log_files: ARRAYED_LIST[separate LOG_FILE]
			l_loggers: ARRAYED_LIST[separate LOGGER]
			i: INTEGER
		do
			create l_loggers.make (a_clients)
			create l_connections.make (a_log_file_addresses.count)
			create l_log_files.make (a_log_file_addresses.count)

			across
				a_log_file_addresses as iter
			loop
				create connection.make
				l_connections.extend (connection)
				connection.connect (iter.item.address, iter.item.port)
				if
					connection.is_initialized and then
					attached {separate LOG_FILE} connection.get_remote_index as log_file
				then
					l_log_files.extend (log_file)
				else
					io.error.put_string ("Couldn't connect to server .%N")
				end
			end

			from
				i := 1
			until
				i > a_clients
			loop
				l_loggers.extend (create {separate LOGGER}.make)
				i := i + 1
			end

			across
				l_loggers as iter
			loop
				separate iter.item as logger do
					across
						l_log_files as iter2
					loop
						logger.add_log_file (iter2.item)
					end
					logger.test (a_entries, create {ESTRING_8}.make_from_string_8 (iter.out))
				end
			end

			across
				l_loggers as iter
			loop
				separate iter.item as logger do
					if io = logger.io then
						do_nothing
					end
				end
			end

			exit

		end
feature
	name: ESTRING_8
		once
			Result := "log"
		end

	call (a_arguments: LIST[ESTRING_8])
		local
			i: INTEGER
			l_address_list: ARRAYED_LIST[TUPLE[ESTRING_8, NATURAL_16]]
		do
			if a_arguments.count > 0 then
				if a_arguments[1] ~ "client" then
					if
						a_arguments.count >= 5 and then
						attached a_arguments[2].to_integer as clients and then
						attached a_arguments[3].to_integer as entries
					then
						create l_address_list.make ((a_arguments.count - 3)//2)
						from
							i := 5
						until
							i > a_arguments.count
						loop
							if
								attached a_arguments[i-1] as address and then
								attached a_arguments[i].to_natural_16 as port
							then
								l_address_list.extend ([create {ESTRING_8}.make_from_string_8 (address), port])
							end
							i := i + 2
						end
						run_logger (clients, entries, l_address_list)
					else
						print_usage
					end
				elseif a_arguments[1] ~ "server" then
					if
						a_arguments.count = 2 and then
						attached a_arguments[2].to_natural_16 as port
					then
						run_log_file (port)
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
			print ("Usage: log client <address> <port> <clients_count> <entries_count> or%N")
			print ("       log server <port>%N")
		end

	exit
		external "C inline" alias "exit(0);" end
end
