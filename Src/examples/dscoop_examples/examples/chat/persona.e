note
	description: "{PERSONA} is the representation of the user in a chat room."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class PERSONA

create
	make

feature
	room: separate CHAT_ROOM
	name: ESTRING_8
	message_count: INTEGER_32 do Result := messages.count end
	logged_in: BOOLEAN

	make (a_name: ESTRING_8; a_room: separate CHAT_ROOM)
		do
			name := a_name
			room := a_room
			logged_in := True
		end

	message (a_index: INTEGER): ESTRING_8
			-- Retrieve the message with id `a_index'
		require
			a_index > 0 and a_index <= message_count
		do
			Result := messages[a_index]
		end

	say (a_msg: ESTRING_8)
		local
			a_line: ESTRING_8
		do
			a_line := name + ": " + a_msg
			print (a_line + "%N")
			separate room as cr do
				across cr.personas as iter loop
					separate iter.item as cp do
						cp.add_message (a_line)
					end
				end
			end
		end

	add_message (a_msg: ESTRING_8)
		do
			messages.extend (a_msg)
		end

	log_out
		do
			separate room as cr do cr.personas.remove (name) end
			logged_in := False
		end

feature {NONE}
	messages: ARRAYED_LIST[ESTRING_8]
		attribute
			create Result.make (512)
		end

end
