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

	start_server (a_index_object: detachable separate ANY; a_port: NATURAL_16)
		do
			separate server as c_server do
				c_server.set_index_object (a_index_object)
				c_server.start_incoming (a_port)
			end
		end

	connect (a_address: ESTRING_8; a_port: NATURAL_16)
			-- Connect to `a_address' on port `a_port' and store it's index object in `last_index_object'
		local
			l_connection: separate DSCOOP_CONNECTION
		do
			create <NONE> l_connection.make
			separate l_connection as c_connection do
				c_connection.connect (a_address, a_port)
				if c_connection.is_initialized then
					last_index_object := c_connection.get_remote_index
				else
					last_index_object := Void
				end
			end
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
			-- The address of the current node
		do
			separate server as c_server do
				Result := c_server.address
			end
		end

	node_port: NATURAL_16
			-- The port of the current node
		do
			separate server as c_server do
				Result := c_server.port
			end
		end

	last_index_object: detachable separate ANY
			-- The index object of the connection established with a previous call to `connect'

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

	remove_connection (a_nid: NATURAL_64)
		do
			separate server as c_server do
				c_server.connections.remove (a_nid)
			end
		end

	init_structures
		external
			"C use eif_dscoop.h"
		alias
			"eif_dscoop_init"
		end

end
