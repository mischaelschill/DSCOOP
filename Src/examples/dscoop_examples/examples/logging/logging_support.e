note
	description: "Summary description for {LOGGING_SUPPORT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	LOGGING_SUPPORT

create
	make

feature {NONE}
	make (a_logger: separate LOGGER)
		do
			logger := a_logger
		end

feature
	logger: separate LOGGER

	start_test_run (a_name: ESTRING_8; a_entries: NATURAL)
		local
			i: NATURAL
			a_content: ESTRING_8
		do
			from
				i := 1
				a_content := "A log entry from " + a_name.out
			until
				i > a_entries
			loop
				separate logger as l do
					l.log (a_content)
				end
			end
		end

end
