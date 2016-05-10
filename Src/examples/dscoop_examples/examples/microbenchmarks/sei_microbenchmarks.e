note
	description: "{DSCOOP_MICROBENCHMARKS} runs some very simple benchmarks."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	DSCOOP_MICROBENCHMARKS

inherit
	DATETIME_SUPPORT
	CLI_COMMAND

feature
	name: ESTRING_8
		once
			Result := "micro"
		end

	call (a_arguments: LIST[ESTRING_8])
		do
			if a_arguments.count > 0 then
				if a_arguments[1] ~ "commands" then
					if
						a_arguments.count = 4 and then
						attached a_arguments[2] as address and then
						attached a_arguments[3].to_natural_16 as port and then
						attached a_arguments[4].to_natural as count
					then
						run_command_benchmark (address, port, count)
					else
						print_usage
					end
				elseif a_arguments[1] ~ "queries" then
					if
						a_arguments.count = 4 and then
						attached a_arguments[2] as address and then
						attached a_arguments[3].to_natural_16 as port and then
						attached a_arguments[4].to_integer as count
					then
						run_query_benchmark (address, port, count)
					else
						print_usage
					end
				elseif a_arguments[1] ~ "lock-commands" then
					if
						a_arguments.count = 4 and then
						attached a_arguments[2] as address and then
						attached a_arguments[3].to_natural_16 as port and then
						attached a_arguments[4].to_natural as count
					then
						run_lock_command_benchmark (address, port, count)
					else
						print_usage
					end
				elseif a_arguments[1] ~ "lock-queries" then
					if
						a_arguments.count = 4 and then
						attached a_arguments[2] as address and then
						attached a_arguments[3].to_natural_16 as port and then
						attached a_arguments[4].to_natural as count
					then
						--run_lock_query_benchmark (address, port, count)
					else
						print_usage
					end
				elseif a_arguments[1] ~ "server" then
					if
						a_arguments.count = 2 and then
						attached a_arguments[2].to_natural_16 as port
					then
						start_supplier (port)
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
			print ("Usage: micro commands <address> <port> <count> or%N")
			print ("       micro queries <address> <port> <count> or%N")
			print ("       micro lock-commands <address> <port> <count> or%N")
			print ("       micro lock-queries <address> <port> <count> or%N")
			print ("       micro server <port>%N")
		end
feature
	start_supplier (a_port: NATURAL_16)
		local
			dscoop: DSCOOP
		do
			-- Create a DSCOOP server
			create dscoop
			separate dscoop.server as c_server do
				-- Export the fork as the index object
				c_server.set_index_object (create {separate DSCOOP_EXAMPLE_SUPPLIER})
				-- Start the server
				c_server.start_incoming (a_port)
			end
		end

	run_command_benchmark (a_supplier_address: ESTRING_8; a_supplier_port: NATURAL_16; a_count: NATURAL)
		local
			start: NATURAL_64
			i: NATURAL
		do
			if attached get_supplier_object (a_supplier_address, a_supplier_port) as supplier then
				separate supplier as s do
					start := current_time_millis
					from
						i := 1
					until
						i > a_count
					loop
						s.command (42)
						i := i + 1
					end
					time := (current_time_millis - start)
					print (time.out + "%N")
				end
			else
				io.error.put_string ("failed to get supplier object%N")
			end
		end

	run_query_benchmark (a_supplier_address: ESTRING_8; a_supplier_port: NATURAL_16; a_count: INTEGER)
		local
			start: NATURAL_64
			i: INTEGER
			tmp: INTEGER
		do
			if attached get_supplier_object (a_supplier_address, a_supplier_port) as supplier then
				separate supplier as s do
					start := current_time_millis
					from
						i := 1
					until
						i > a_count
					loop
						tmp := s.query (i)
						i := i + 1
					end

					time := (current_time_millis - start)
					print (time.out + "%N")
				end
			else
				io.error.put_string ("failed to get supplier object%N")
			end
		end

	run_lock_command_benchmark (a_supplier_address: ESTRING_8; a_supplier_port: NATURAL_16; a_count: NATURAL)
		local
			start: NATURAL_64
			i: NATURAL
		do
			if attached get_supplier_object (a_supplier_address, a_supplier_port) as supplier then
				start := current_time_millis
				from
					i := 1
				until
					i > a_count
				loop
					separate supplier as s do
						s.command (42)
					end
					i := i + 1
				end
				time := (current_time_millis - start)
				print (time.out + "%N")
			else
				io.error.put_string ("failed to get supplier object%N")
			end
		end

	run_lock_query_benchmark (a_supplier_address: ESTRING_8; a_supplier_port: NATURAL_16; a_count: NATURAL)
		local
			start: NATURAL_64
			i: NATURAL
			tmp: INTEGER
		do
			if attached get_supplier_object (a_supplier_address, a_supplier_port) as supplier then
				start := current_time_millis
				from
					i := 1
				until
					i > a_count
				loop
					separate supplier as s do
						tmp := s.query (42)
					end
					i := i + 1
				end
				time := (current_time_millis - start)
				print (time.out + "%N")
			else
				io.error.put_string ("failed to get supplier object%N")
			end
		end

	time: NATURAL_64
	connection: detachable DSCOOP_CONNECTION

feature {NONE}
	get_supplier_object (a_supplier_address: ESTRING_8; a_supplier_port: NATURAL_16): detachable separate DSCOOP_EXAMPLE_SUPPLIER
		local
			l_connection: DSCOOP_CONNECTION
		do
			create l_connection.make
			l_connection.connect (a_supplier_address, a_supplier_port)
			-- Checking that the connection is established
			if
				l_connection.is_initialized and then
				attached {separate DSCOOP_EXAMPLE_SUPPLIER} l_connection.get_remote_index as supplier
			then
				Result := supplier
				connection := l_connection
			end
		end
end
