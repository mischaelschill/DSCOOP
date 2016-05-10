note
	description: "A {FORK} is needed by the philosopher to eat."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	FORK

feature
	use: NATURAL
		do
		end

feature {NONE}
	ee: EXECUTION_ENVIRONMENT
		once
			create Result
		end

end
