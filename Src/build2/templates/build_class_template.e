indexing
	description: "Objects that represent an EV_TITLED_WINDOW generated by Build."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	<CLASS_NAME>

inherit
	EV_TITLED_WINDOW
		redefine
			initialize
		end

feature {NONE} -- Initialization

	initialize is
			-- Initialize `Current'.
		local
			<LOCAL>
		do
			Precursor {EV_TITLED_WINDOW}

				-- Create all widgets.
			<CREATE>

				-- Build widget structure.
			<BUILD>

				-- Initialize properties of all widgets.<SET>
		end

end -- class <CLASS_NAME>
