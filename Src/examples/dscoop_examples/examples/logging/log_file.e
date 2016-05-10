note
	description: "{LOG_FILE} collects log data."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	LOG_FILE

create
	make

feature {NONE}
	make
		do
			create content.make (64)
		end

feature
	content: ARRAYED_LIST[ESTRING_8]

feature
	write_entry (a_data: ESTRING_8)
		do
			content.extend (a_data)
		end

end
