note
	description: "Summary description for {PRODUCER_CONSUMER}."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	PRODUCER_CONSUMER

inherit
	CLI_COMMAND

feature

	name: ESTRING_8
		once
			Result := "prodcons"
		end

	call (a_arguments: LIST[ESTRING_8])
		do
			if a_arguments.count > 0 then
				if a_arguments[1] ~ "producer" then
					if
						a_arguments.count = 3 and then
						attached a_arguments[2] as address and then
						attached a_arguments[3].to_natural_16 as port
					then
						run_producer (address, port)
					else
						print_usage
					end
				elseif a_arguments[1] ~ "consumer" then
					if
						a_arguments.count = 3 and then
						attached a_arguments[2] as address and then
						attached a_arguments[3].to_natural_16 as port
					then
						run_consumer (address, port)
					else
						print_usage
					end
				elseif a_arguments[1] ~ "buffer" then
					if
						a_arguments.count = 2 and then
						attached a_arguments[2].to_natural_16 as port
					then
						run_buffer (port)
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
			print ("Usage: prodcons producer <buffer address> <buffer port> or%N")
			print ("Usage: prodcons consumer <buffer address> <buffer port> or%N")
			print ("       prodcons buffer <port>%N")
		end

feature
	run_buffer (a_port: NATURAL_16)
		local
			l_common: SEI
		do
			-- Create a SEI server
			create l_common
			separate l_common.server as l_server do
				-- Export the fork as the index object
				l_server.set_index_object (create {separate BUFFER}.make (4))
				-- Start the server
				l_server.start_incoming (a_port)
			end
		end

	run_producer (a_buf_address: ESTRING_8; a_port: NATURAL_16)
			-- Creates a new philosopher by connecting to two remote forks
		local
			connection: SEI_CONNECTION
			producer: PRODUCER
		do
			create connection.make
			connection.connect (a_buf_address, a_port)
			-- Checking that the connections are established
			if connection.is_initialized then
				if
					attached {separate BUFFER} connection.get_remote_index as buf then
					create producer.make (buf)
					producer.produce (1000)
				else
					print ("Unexpected index objects.%N")
				end
			else
				print ("Unable to connect.%N")
			end
		end

	run_consumer (a_buf_address: ESTRING_8; a_port: NATURAL_16)
			-- Creates a new philosopher by connecting to two remote forks
		local
			connection: SEI_CONNECTION
			consumer: CONSUMER
		do
			create connection.make
			connection.connect (a_buf_address, a_port)
			-- Checking that the connections are established
			if connection.is_initialized then
				if
					attached {separate BUFFER} connection.get_remote_index as buf then
					create consumer.make (buf)
					consumer.consume (1000)
				else
					print ("Unexpected index objects.%N")
				end
			else
				print ("Unable to connect.%N")
			end
		end
end
