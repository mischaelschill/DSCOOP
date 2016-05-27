note
	description: "The {DSCOOP_POSTMAN} receives messages and then distributes them to recipients."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	DSCOOP_POSTMAN

create {DSCOOP_CONNECTION}
	make

feature {NONE}
	make (a_connection: separate DSCOOP_CONNECTION)
			-- Creates a new postman working for connection `a_connection'
		do
			connection := a_connection
			connection_c := a_connection.connection
		ensure
			connection = a_connection
		end

feature
	start
			-- Start the connection
		local
			error: INTEGER
			ee: EXECUTION_ENVIRONMENT
		do
			process_messages_c (connection_c)
			separate connection as c_connection do
				deregister_connection_c (c_connection.remote_id)
			end
		end

	connection: separate DSCOOP_CONNECTION

feature {NONE} -- Internals
	connection_c: POINTER
		-- The internal connection structure

	process_messages_c (a_connection: POINTER)
			-- Processes messages until connection is closed
		external
			"built_in"
		end

	deregister_connection_c (a_remote_nid: NATURAL_64)
		external
			"C use eif_dscoop.h"
		alias
			"eif_dscoop_deregister_connection"
		end

	exit
		external "C inline" alias "exit(0);" end

end
