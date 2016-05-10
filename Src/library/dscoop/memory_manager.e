note
	description: "{MEMORY_MANAGER} handles memory allocation for ESTRINGs."
	author: "Mischael Schill"
	date: "$Date: 2015-04-02 11:34:31 +0200 (Do, 02 Apr 2015) $"
	revision: "$Revision: 1145 $"

class
	MEMORY_MANAGER

feature {MEMORY_MANAGER_ACCESS}
	allocate_memory (a_count: INTEGER_32): MANAGED_POINTER
			-- Allocate some memory and return a pointer to it
		require
			a_count >= 0
		do
			create Result.make (a_count)
		end

	own_memory (a_pointer: POINTER; a_count: INTEGER_32): MANAGED_POINTER
			-- Own the memory at `a_pointer'
		require
			a_count >= 0
			not a_pointer.is_default_pointer
		do
			create Result.own_from_pointer (a_pointer, a_count)
		end

end
