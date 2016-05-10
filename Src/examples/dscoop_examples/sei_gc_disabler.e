note
	description: "{DSCOOP_GC_DISABLER} disables the garbage collection, handles multiple requests by counting."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	DSCOOP_GC_DISABLER

create {DSCOOP_GC_SUPPORT}
	make

feature
	make
		do
			create memory
		end

	memory: MEMORY

	disable_gc
		do
			if counter = 0 then
				memory.collection_off
			end
			counter := counter + 1
		end

	enable_gc
		do
			counter := counter - 1
			if counter = 0 then
				memory.collection_on
			end
		end


feature {NONE} -- Implementation
	counter: INTEGER

end
