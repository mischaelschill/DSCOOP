note
	description: "The {PIPELINE_EXAMPLE} represents different connected remote services."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	PIPELINE_EXAMPLE

inherit
	CLI_COMMAND
	DATETIME_SUPPORT

feature
	name: ESTRING_8
		once
			Result := "pipeline"
		end

	call (a_arguments: LIST[ESTRING_8])
		do
			if a_arguments.count > 0 then
				if a_arguments[1] ~ "rooter" then
					if
						a_arguments.count = 4 and then
						attached a_arguments[2].to_natural_16 as port and then
						attached a_arguments[3] as supplier_address and then
						attached a_arguments[4].to_natural_16 as supplier_port
					then
						run_rooter (port, supplier_address, supplier_port)
					else
						print_usage
					end
				elseif a_arguments[1] ~ "squarer" then
					if
						a_arguments.count = 4 and then
						attached a_arguments[2].to_natural_16 as port and then
						attached a_arguments[3] as supplier_address and then
						attached a_arguments[4].to_natural_16 as supplier_port
					then
						run_squarer (port, supplier_address, supplier_port)
					else
						print_usage
					end
				elseif a_arguments[1] ~ "adder" then
					if
						a_arguments.count = 6 and then
						attached a_arguments[2].to_natural_16 as port and then
						attached a_arguments[3] as supplier_address_1 and then
						attached a_arguments[4].to_natural_16 as supplier_port_1 and then
						attached a_arguments[5] as supplier_address_2 and then
						attached a_arguments[6].to_natural_16 as supplier_port_2
					then
						run_adder (port, supplier_address_1, supplier_address_2, supplier_port_1, supplier_port_2)
					else
						print_usage
					end
				elseif a_arguments[1] ~ "producer" then
					if
						a_arguments.count = 3 and then
						attached a_arguments[2].to_natural_16 as port and then
						attached a_arguments[3].to_natural as number
					then
						run_producer (port, number)
					else
						print_usage
					end
				elseif a_arguments[1] ~ "consumer" then
					if
						a_arguments.count = 4 and then
						attached a_arguments[2] as address and then
						attached a_arguments[3].to_natural_16 as port and then
						attached a_arguments[4].to_integer as count
					then
						run_consumer (address, port, count)
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
			print ("Usage: pipeline producer <port> <number> or%N")
			print ("Usage: pipeline rooter <port> <input address> <input port> or%N")
			print ("Usage: pipeline squarer <port> <input address> <input port> or%N")
			print ("Usage: pipeline adder <port> <input address 1> <input port 1> <input address 2> <input port 2> or%N")
			print ("Usage: pipeline consumer <input address> <input port>%N")
		end

feature
	dscoop: DSCOOP
		attribute
			create Result
		end

	run_producer (a_port: NATURAL_16; a_count: NATURAL)
		local
			l_stage: separate PIPELINE_STAGE
		do
			-- Create a DSCOOP server
			separate dscoop.server as c_server do
				-- Export the fork as the index object
				create l_stage
				c_server.set_index_object (l_stage)
				-- Start the server
				c_server.start_incoming (a_port)
			end
			across
				1 |..| a_count.as_integer_32 as iter
			loop
				stage_produce (l_stage)
			end

			separate l_stage as c_stage do
				c_stage.finish
			end
		end

	random: RANDOM
		attribute
			create Result.make
			Result.start
		end

	stage_produce (a_stage: separate PIPELINE_STAGE)
		require
			not a_stage.has_new_data
		do
			if not a_stage.has_new_data then
				a_stage.produce (random.double_item)
				random.forth
			end
		end

	run_consumer (a_supplier_address: ESTRING_8; a_supplier_port: NATURAL_16; a_count: INTEGER)
		local
			l_stage: separate PIPELINE_STAGE
			l_finished: BOOLEAN
			start: NATURAL_64
			i: INTEGER
		do
			if attached get_stage (a_supplier_address, a_supplier_port) as supplier then
				create l_stage
				start := current_time_millis
				from
					l_finished := False
					i := 1
				until
					l_finished or i > a_count
				loop
					separate l_stage as c_stage do
						c_stage.consume (supplier)
						l_finished := c_stage.is_finished
					end
					i := i + 1
				end
				print ((current_time_millis - start).out + "%N")
			else
				io.error.put_string ("failed to get supplier object%N")
			end
		end

	run_adder (a_port: NATURAL_16; a_address_1, a_address_2: ESTRING_8; a_port_1, a_port_2: NATURAL_16)
			-- Creates a new philosopher by connecting to two remote forks
		local
			start: NATURAL_64
			l_stage: separate PIPELINE_STAGE
			l_finished: BOOLEAN
			l_formatter: FORMAT_STRING
		do
			separate dscoop.server as c_server do
				-- Export the fork as the index object
				create l_stage
				c_server.set_index_object (l_stage)
				-- Start the server
				c_server.start_incoming (a_port)
			end
			if
				attached get_stage (a_address_1, a_port_1) as supplier_1 and then
				attached get_stage (a_address_2, a_port_2) as supplier_2
			then
				start := current_time_millis
				from
					l_finished := False
				until
					l_finished
				loop
					separate l_stage as c_stage do
						c_stage.add (supplier_1, supplier_2)
						l_finished := c_stage.is_finished
					end
				end
				print ((current_time_millis - start).out + "%N")
			else
				io.error.put_string ("failed to get supplier objects%N")
			end
		end

	run_squarer (a_port: NATURAL_16; a_supplier_address: ESTRING_8; a_supplier_port: NATURAL_16)
		local
			start: NATURAL_64
			l_stage: separate PIPELINE_STAGE
			l_finished: BOOLEAN
		do
			create l_stage
			separate dscoop.server as c_server do
				-- Export the fork as the index object
				create l_stage
				c_server.set_index_object (l_stage)
				-- Start the server
				c_server.start_incoming (a_port)
			end
			if attached get_stage (a_supplier_address, a_supplier_port) as supplier then
				start := current_time_millis
				from
					l_finished := False
				until
					l_finished
				loop
					separate l_stage as c_stage do
						c_stage.square (supplier)
						l_finished := c_stage.is_finished
					end
				end
				print ((current_time_millis - start).out + "%N")
			else
				io.error.put_string ("failed to get supplier object%N")
			end
		end

	run_rooter (a_port: NATURAL_16; a_supplier_address: ESTRING_8; a_supplier_port: NATURAL_16)
		local
			start: NATURAL_64
			l_stage: separate PIPELINE_STAGE
			l_finished: BOOLEAN
		do
			create l_stage
			separate dscoop.server as c_server do
				-- Export the fork as the index object
				create l_stage
				c_server.set_index_object (l_stage)
				-- Start the server
				c_server.start_incoming (a_port)
			end
			if attached get_stage (a_supplier_address, a_supplier_port) as supplier then
				start := current_time_millis
				from
					l_finished := False
				until
					l_finished
				loop
					separate l_stage as c_stage do
						c_stage.root (supplier)
						l_finished := c_stage.is_finished
					end
				end
				print ((current_time_millis - start).out + "%N")
			else
				io.error.put_string ("failed to get supplier object%N")
			end
		end

feature {NONE} -- Implementation
	get_stage (a_supplier_address: ESTRING_8; a_supplier_port: NATURAL_16): detachable separate PIPELINE_STAGE
		local
			l_connection: DSCOOP_CONNECTION
		do
			create l_connection.make
			l_connection.connect (a_supplier_address, a_supplier_port)
			-- Checking that the connection is established
			if
				l_connection.is_initialized and then
				attached {separate PIPELINE_STAGE} l_connection.get_remote_index as supplier
			then
				Result := supplier
			else
				io.error.put_string ("Couldn't get index from " + a_supplier_address.out + ":" + a_supplier_port.out + "%N")
			end
		end
end
