note
	description: "{DSCOOP_CONNECTION} is the Eiffel representation of a SEI connection. It is backed by a native C struct used by the runtime."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	DSCOOP_CONNECTION

inherit
	DISPOSABLE
		rename
			dispose as close
		end

create
	make

feature {NONE}
	make
			-- Initializes SEI and creates an empty socket
		local
			dscoop: DSCOOP
		do
			create dscoop
			dscoop.init_dscoop
			create socket.make_empty
		end

feature -- Access
	socket: NETWORK_STREAM_SOCKET
			-- The socket through which the communication happens

	remote_id: NATURAL_64
			-- The id of the connected node

	index: detachable separate ANY

feature -- Status Report
	is_initialized: BOOLEAN
			-- Whether this connection is initialized

feature
	connect (a_remote_address: ESTRING_8; a_remote_port: NATURAL_16)
			-- Connect to a specific address and port
		require
			not is_initialized
		local
			l_factory: INET_ADDRESS_FACTORY
			dscoop: DSCOOP
		do
			create l_factory
			if attached l_factory.create_from_name (a_remote_address.out) as address then
				create socket.make
				socket.set_blocking
				socket.set_peer_address (create {NETWORK_SOCKET_ADDRESS}.make_from_address_and_port (address, a_remote_port))
				socket.connect
				if socket.is_connected then
					init
					if is_initialized then
						start_processing
					end
				end
			end
		end

	init
			-- Run the initialization protocol
		require
			socket.is_open_read
			socket.is_open_write
		local
			dscoop: DSCOOP
			formatter: FORMAT_STRING
			l_args: LIST[STRING_8]
			l_address: C_STRING
			l_port: NATURAL_16
		do
			create dscoop
			create formatter
			-- The initialization protocol is symmetrical: both say hello and give their node id
			-- Unlike the rest of the protocol, this is textual. This makes it simpler to change to a different protocol in the future, if necessary.
			if dscoop.node_port > 0 then
				socket.put_string (
					formatter.apply_format_8 ("HELLO $u $s $u%N", dscoop.node_id, dscoop.node_address, dscoop.node_port)
					)
			else
				socket.put_string (
					formatter.apply_format_8 ("HELLO $u%N", dscoop.node_id)
					)
			end
			socket.read_line_until (1024);
			if socket.last_string.starts_with ("HELLO ") then
				l_args := socket.last_string.split (' ')
				if l_args.count >= 2 then
					remote_id := l_args[2].to_natural_64
					if l_args.count >= 4 then
						create l_address.make (l_args[3])
						l_port := l_args[4].to_natural_16
						connection := register_connection_c (socket.descriptor, remote_id, l_address.item, l_port)
					else
						connection := register_connection_c (socket.descriptor, remote_id, create {POINTER}, 0)
					end
					is_initialized := True
					separate dscoop.server as c_server do
						c_server.register_connection (Current)
						index := c_server.index_object
					end
				end

			else
				socket.close
			end
		end

	start_processing
			-- Start the processing of incoming requests.
		require
			is_initialized
		do
			create listener.make (Current)
			if attached listener as l then
				separate l as cl do
					-- The postman fetches messages and relays them to the right recipient
					cl.start
				end
			end
		end

	set_index (a_object: separate ANY)
			-- Add an object to a register
		require
			is_initialized
		do
			index := a_object
			set_index_c (connection, a_object)
		end

	get_remote_index: detachable separate ANY
			-- Retrieve the remote index object
		require
			is_initialized
		do
			Result := get_remote_index_c (remote_id)
		end

	close
			-- Closes the connection. Will cause exceptions of there are still remote objects in use!
		do
			if socket.is_connected then
				socket.close
			end
			is_initialized := False
		end

feature {DSCOOP_POSTMAN}
	connection: POINTER
		-- A pointer to the internal connection struct

feature {NONE}
	listener: detachable separate DSCOOP_POSTMAN
		-- Fetches messages from the network and delivers them to the proper recipients

	set_index_c (a_connection: POINTER; a_object: separate ANY)
		external
			"C inline use eif_dscoop.h"
		alias
			"eif_dscoop_connection_set_index_object ($a_connection, eif_access($a_object))"
		end

	get_remote_index_c (a_remote_nid: NATURAL_64): detachable separate ANY
		external
			"C use eif_dscoop.h"
		alias
			"eif_dscoop_get_remote_index"
		end

	register_connection_c (a_socket: INTEGER; a_remote_nid: NATURAL_64; a_address: POINTER; a_port: NATURAL_16): POINTER
		external
			"C use eif_dscoop.h"
		alias
			"eif_dscoop_register_connection"
		end
end

