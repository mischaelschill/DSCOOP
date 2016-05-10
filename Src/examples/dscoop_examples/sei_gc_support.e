note
	description: "{SEI_GC_SUPPORT} provides access to the garbage collector disabler."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	SEI_GC_SUPPORT

feature -- Access
	disabler: separate SEI_GC_DISABLER
		once ("PROCESS")
			create Result.make
		end

end
