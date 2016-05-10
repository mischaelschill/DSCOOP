note
	description: "{DSCOOP_SERVER} manages the server part of SEI, allowing for incoming connections."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	DSCOOP_SERVER

create {DSCOOP}
	make

feature {NONE} -- Initialization
	make
		do
			proxy_anchor := Void
			set_address_auto
		end

feature -- Access
	index_object: detachable separate ANY assign set_index_object;
			-- The object an external connection can receive by issuing a "get"

	connections: ARRAYED_SET[separate DSCOOP_CONNECTION]
			-- All connections made registered with the server
		attribute
			create Result.make (10)
		end

	port: NATURAL_16

	address: ESTRING_8

feature
	set_index_object (a_object: detachable separate ANY)
			-- Setter for `index_object'
		do
			index_object := a_object
		end

	start_incoming (a_port: NATURAL_16)
			-- Start listening to `a_port' on all interfaces.
		do
			separate incoming as i do
				i.listen (a_port)
				port := a_port
			end
		ensure
			port = a_port
		end

	set_address_auto
			-- Sets the address given to incoming connections for auto-connect to the default hostname
		local
			l_addr: INET_ADDRESS_IMPL_V4
		do
			create l_addr
			address := l_addr.local_host_name
		end

	set_address (a_address: ESTRING_8)
			-- Sets the address given to incoming connections for auto-connect
		do
			address := a_address
		ensure
			address ~ a_address
		end

--	start_incoming_on_address (a_address: ESTRING_8)
--			-- Start listening to `a_port' on a specific address. Also sets `address'
--		do
--			separate incoming as i do
--				i.listen (a_address, a_port)
--				address := a_address
--				port := a_port
--			end
--		ensure
--			address ~ a_address
--			port = a_port
--		end

feature {DSCOOP_CONNECTION, DSCOOP_SERVER_LISTENER}

	register_connection (a_connection: separate DSCOOP_CONNECTION)
			-- Register the given connection with the server. Sets the index object.
		require
			a_connection.is_initialized
		do
			if attached index_object as obj then
				a_connection.set_index (obj)
			end
			if a_connection.is_initialized then
				connections.extend (a_connection)
			end
		end

	remove_connection (a_connection: separate DSCOOP_CONNECTION)
			-- Deregister the given connection with the server.
		do
			connections.prune (a_connection)
		end

feature {NONE} -- Internals
	incoming: separate DSCOOP_SERVER_LISTENER
			-- The processor that waits for new connections
		attribute
			create Result
		end

	proxy_anchor: detachable DSCOOP_PROXY_OBJECT
		-- This attribute is never set, it is just there to make sure that the SEI_PROXY_OBJECT class is compiled
end
