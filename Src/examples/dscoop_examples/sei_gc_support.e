note
	description: "{DSCOOP_GC_SUPPORT} provides access to the garbage collector disabler."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	DSCOOP_GC_SUPPORT

feature -- Access
	disabler: separate DSCOOP_GC_DISABLER
		once ("PROCESS")
			create Result.make
		end

end
