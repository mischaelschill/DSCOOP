note
	description: "Summary description for {MESSAGING_SERVER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MESSAGING_SERVER

create
	make

feature {NONE}
	make
		do

		end

feature --Access
	register: HASH_TABLE[separate MESSAGING_CLIENT, ESTRING_8]
		attribute
			create Result.make (5)
		end

end
