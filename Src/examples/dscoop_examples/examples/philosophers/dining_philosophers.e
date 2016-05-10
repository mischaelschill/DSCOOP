note
	description: "{DINING_PHILOSOPHERS} is a classic example for deadlocks."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	DINING_PHILOSOPHERS

inherit
	DATETIME_SUPPORT
	CLI_COMMAND

feature

	name: ESTRING_8
		once
			Result := "dp"
		end

	call (a_arguments: LIST[ESTRING_8])
		do
			if a_arguments.count > 0 then
				if a_arguments[1] ~ "philosopher" then
					if
						a_arguments.count = 7 and then
						attached a_arguments[2] as l_name and then
						attached a_arguments[3] as left_address and then
						attached a_arguments[4].to_natural_16 as left_port and then
						attached a_arguments[5] as right_address and then
						attached a_arguments[6].to_natural_16 as right_port and then
						attached a_arguments[7].to_natural as count
					then
						run_philosopher (l_name, left_address, right_address, left_port, right_port, count)
					else
						print_usage
					end
				elseif a_arguments[1] ~ "fork" then
					if
						a_arguments.count = 2 and then
						attached a_arguments[2].to_natural_16 as port
					then
						run_fork (port)
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
			print ("Usage: dp philosopher <name> <left address> <left port>  <right address> <right port> <count> or%N")
			print ("       dp fork <port>%N")
		end

feature
	run_philosopher (a_name, a_left_fork_address, a_right_fork_address: ESTRING_8; a_left_fork_port, a_right_fork_port: NATURAL_16; a_count: NATURAL)
			-- Creates a new philosopher by connecting to two remote forks
		local
			left_connection, right_connection: DSCOOP_CONNECTION
			philosopher: PHILOSOPHER
		do
			create left_connection.make
			-- Connecting to the process of the left fork
			left_connection.connect (a_left_fork_address, a_left_fork_port)
			create right_connection.make
			-- Connecting to the process of the right fork
			right_connection.connect (a_right_fork_address, a_right_fork_port)
			-- Checking that the connections are established
			if left_connection.is_initialized and then right_connection.is_initialized and then
				attached {separate FORK} left_connection.get_remote_index as left and then
				attached {separate FORK} right_connection.get_remote_index as right
			then
				-- Actually creating the philosopher
				create philosopher.place (a_name, left, right)
				philosopher.eat (a_count)
				philosopher.name.do_nothing
				left_connection.close
				right_connection.close
			else
				io.error.put_string ("Unable to connect.%N")
			end
		end

	run_fork (a_port: NATURAL_16)
		local
			dscoop: DSCOOP
		do
			-- Create a DSCOOP server
			create dscoop
			separate dscoop.server as c_server do
				-- Export the fork as the index object
				c_server.set_index_object (create {separate FORK})
				-- Start the server
				c_server.start_incoming (a_port)
			end
		end

end
