note
	description: "{SEI_COMPENSATION_SUPPORT} is the interface for registering SEI compensations."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	DSCOOP_COMPENSATION_SUPPORT

feature
	frozen compensation (a_compensation_agent: PROCEDURE)
			-- Register a new compensation unoing what the current processor did in case a client disconnects prematurely
		do
			register_compensation (a_compensation_agent)
		end

feature {NONE} -- Implementation
	frozen register_compensation (a_compensation_agent: PROCEDURE)
		external
			"built_in"
		end
end
