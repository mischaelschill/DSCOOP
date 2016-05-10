note
	description: "A simple {CHAT_SERVER} supporting multiple chat rooms."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	CHAT_SERVER

feature
	rooms: HASH_TABLE[separate CHAT_ROOM, ESTRING_8]
		attribute
			create Result.make (5)
			Result["lobby"] := create {separate CHAT_ROOM}
		end

	persona: detachable separate PERSONA

	log_in (a_room, a_name: ESTRING_8)
		do
			print (a_name.out + " has logged in.%N")
			if attached rooms[a_room] as room then
				separate room as cr do
					cr.log_in (a_name)
					persona := cr.persona
				end
			end
		end
end
