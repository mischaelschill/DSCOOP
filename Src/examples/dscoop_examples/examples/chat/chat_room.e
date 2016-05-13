note
	description: "Summary description for {CHAT_ROOM}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class CHAT_ROOM
feature
	personas: HASH_TABLE[separate PERSONA, STRING_8]
		attribute
			create Result.make (16)
		end

	persona: detachable separate PERSONA

	log_in (a_name: ESTRING_8)
		do
			if not personas.has (a_name) then
				personas[a_name] := create {separate PERSONA}.make (a_name, Current)
				persona := personas[a_name]
			end
		end
end
