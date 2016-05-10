note
	description: "{SEI_EXAMPLE_SUPPLIER} is providing some features to test calls."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	SEI_EXAMPLE_SUPPLIER

feature
	command (a_argument: INTEGER)
		do
		end

	query (a_argument: INTEGER): INTEGER
		do
			Result := a_argument
		end
end
