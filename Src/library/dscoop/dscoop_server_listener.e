note
	description: "{DSCOOP_SERVER_LISTENER} handles incoming connections."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	DSCOOP_SERVER_LISTENER

create {DSCOOP_SERVER}
	default_create

feature
	listening_socket: NETWORK_STREAM_SOCKET
			-- The socket to listen for connections
		attribute
			create Result.make
		end

	listen (a_port: NATURAL_16)
			-- Start listening on `a_port' for incoming connections.
		local
			l_connection: separate DSCOOP_CONNECTION
		do
			listening_socket.set_address (create {NETWORK_SOCKET_ADDRESS}.make_any_local (a_port))
			listening_socket.bind
			listening_socket.listen (4)
			from
			until
				False
			loop
				create l_connection.make
				separate l_connection as c do
					listening_socket.accept_to (c.socket)
					c.init
					-- Only after adding the index object should the processing start
					c.start_processing
				end
			end
		rescue
			retry
		end
end
