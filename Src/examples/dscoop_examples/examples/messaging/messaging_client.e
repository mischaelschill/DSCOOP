note
	description: "Summary description for {MESSAGING_CLIENT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MESSAGING_CLIENT

create
	make

feature {NONE}
	make (a_name: ESTRING_8; a_server: separate MESSAGING_SERVER)
		do
			server := a_server
			name := a_name
			a_server.register[a_name] := Current
		end

feature
	name: ESTRING_8
	server: separate MESSAGING_SERVER

	messages: ARRAYED_QUEUE[ESTRING_8]
		attribute
			create Result.make (5)
		end

	deliver_message (a_message: ESTRING_8)
		do
			messages.extend (a_message)
		end

	send_message (a_recipient, a_message: ESTRING_8)
		local
			l_recipient: separate MESSAGING_CLIENT
		do
			l_recipient := wait_for_client (server, a_recipient)
			separate l_recipient as c_recipient do
				c_recipient.deliver_message (a_message)
			end
		end

	wait_for_client (a_server: like server; a_client: ESTRING_8): separate MESSAGING_CLIENT
		require
			a_server.register.has(a_client)
		do
			check attached a_server.register[a_client] as cl then
				Result := cl
			end
		end
end
