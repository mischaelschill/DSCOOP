indexing
	description: "Objects that represent an EV_TITLED_WINDOW.%
		%The original version of this class was generated by EiffelBuild."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	<CLASS_NAME>

<INHERITANCE>

-- This class is the implementation of an EV_TITLED_WINDOW generated by EiffelBuild.
-- You should not modify this code by hand, as it will be re-generated every time
-- modifications are made to the project.

feature {NONE}-- Initialization

	initialize is
			-- Initialize `Current'.
		<LOCAL>
			internal_font: EV_FONT
			internal_pixmap: EV_PIXMAP
		do
			<PRECURSOR>
			<CREATE>
			create internal_pixmap
			<BUILD>
			<SET>
			<EVENT_CONNECTION>

				-- Call `user_initialization'.
			user_initialization
		end
<CUSTOM_FEATURE>

<ATTRIBUTE>

feature {NONE} -- Implementation

	is_in_default_state: BOOLEAN is
			-- Is `Current' in its default state?
		do
			-- Re-implement if you wish to enable checking
			-- for `Current'.
			Result := True
		end
	
	user_initialization is
			-- Feature for custom initialization, called at end of `initialize'.
		deferred
		end
	<EVENT_DECLARATION>

end -- class <CLASS_NAME>
