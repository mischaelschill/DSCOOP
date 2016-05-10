note
	description: "The {CHAT_CLIENT} connects to a remote {CHAT_SERVER} for chatting."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class CHAT_CLIENT

	feature
		persona: detachable separate PERSONA
			-- The remore representation of the client

		connection: separate DSCOOP_CONNECTION
			attribute
				create Result.make
			end

		start (a_server: ESTRING_8; a_port: NATURAL_16; a_room, a_user: ESTRING_8)
				-- Start the chat client
			local
				stopped: BOOLEAN
				fetcher: separate FETCHER
			do
				separate connection as c do
					c.connect (a_server, a_port)
					if c.is_initialized then
						if attached {separate CHAT_SERVER} c.get_remote_index as server then
							separate server as cs do
								cs.log_in (a_room, a_user)
								persona := cs.persona
								print ("Connected.%N")
							end
						else
							print ("Version conflict.%N")
						end
					end
				end

				if attached persona as p then
					print ("Logged in, welcome!%N")
					create fetcher.make (p)
					separate fetcher as cf do
						cf.start
					end
					from stopped := False until stopped loop
						io.read_line
						separate p as cp do
							if io.last_string ~ "logout" then
								cp.log_out
								stopped := True
							else
								cp.say (create {ESTRING_8}.make_from_string_8(io.last_string))
							end
						end
					end
				else
					print ("Unable to connect to server.%N")
				end
			end

		test (a_server, a_room: ESTRING_8; a_user_number, a_total_users: INTEGER)
				-- Start the client test
			local
				stopped: BOOLEAN
				username: ESTRING_8
				room_name: ESTRING_8
				room: detachable separate CHAT_ROOM
			do
				room_name := "lobby"
				username := "test" + a_user_number.out
				separate connection as c do
					c.connect (a_server, 7777)
					if c.is_initialized then
						if attached {separate CHAT_SERVER} c.get_remote_index as server then
							separate server as cs do
								cs.log_in (a_room, username)
								persona := cs.persona
								room := cs.rooms[room_name]
							end
						else
							print ("Error%N")
						end
					end
				end

				if attached room as r then
					await_users (room, a_total_users)
				end

				if attached persona as p then
					separate p as cp do
						cp.say (create {ESTRING_8}.make_from_string_8("Hello Eiffel World!"))
					end

					test_output (p, a_total_users)
				else
					print ("Unable to connect to server.%N")
				end

				separate connection as c do
					c.close

				end
			end

		await_users (a_room: separate CHAT_ROOM; a_users: INTEGER_32)
			require
				a_room.personas.count >= a_users
			do
				do_nothing
			end

		test_output (a_persona: separate PERSONA; a_total_users: INTEGER)
			require
				a_persona.message_count = a_total_users.as_integer_32
			local
				a_msg: ESTRING_8
				l_message_count: INTEGER
			do
				a_msg := a_persona.message (1).split (':')[2]
				if a_msg ~ " Hello Eiffel World!" then
					a_persona.log_out
					print ("Success%N")
				else
					print ("Fail")
				end
			end
end
