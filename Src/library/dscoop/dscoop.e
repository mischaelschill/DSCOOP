note
	description: "{SEI} provides common information for the SCOOP External Interface."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

frozen class
	DSCOOP

feature
	init_dscoop
			-- Initializes the SEI subsystem
		once ("PROCESS")
			node_id.do_nothing
			init_structures
		end

	server: separate DSCOOP_SERVER
			-- The server handles incoming connections as well as the registration of all connections
		once ("PROCESS")
			init_dscoop
			create Result.make
		end

feature -- Access
	node_id: NATURAL_64
			-- The id of the current node
		external
			"C use eif_dscoop.h"
		alias
			"eif_dscoop_node_id"
		end

	node_address: ESTRING_8
		do
			separate server as c_server do
				Result := c_server.address
			end
		end

	node_port: NATURAL_16
		do
			separate server as c_server do
				Result := c_server.port
			end
		end

feature {NONE} -- Internals
	establish_connection (a_address: POINTER; a_port: NATURAL_16)
		local
			l_connection: separate DSCOOP_CONNECTION
			l_exception: DEVELOPER_EXCEPTION
			l_address: ESTRING_8
		do
			create l_connection.make
			separate l_connection as c_connection do
				create l_address.make_from_c (a_address)
				print ("Auto connect to " + l_address.out + ":" + a_port.out + "%N")
				c_connection.connect (l_address, a_port)
				if not c_connection.is_initialized then
					create l_exception
					print ("Unable to auto-connect...%N")
					l_exception.raise
				end
				print ("Auto connected.%N")
			end
		end

	init_structures
		external
			"C use eif_dscoop.h"
		alias
			"eif_dscoop_init"
		end

end
