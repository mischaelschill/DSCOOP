note
	description: "The {FETCHER} fetches new incoming messages until the user logged out."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class FETCHER

create
	make

feature
	make (a_persona: separate PERSONA) do persona := a_persona end
	persona: separate PERSONA
	stopped: BOOLEAN
	messages: INTEGER
	start
		do
			from stopped := False until stopped loop
				fetch_lines (persona)
			end
		end

	fetch_lines (a_persona: like persona)
		require
			a_persona.message_count > messages or not a_persona.logged_in
		local
			l_count: INTEGER
		do
			from l_count := a_persona.message_count
			until messages = l_count
			loop
				messages := messages + 1
				io.put_string (a_persona.message (messages))
				io.put_new_line
			end
			stopped := not a_persona.logged_in
		end
end
