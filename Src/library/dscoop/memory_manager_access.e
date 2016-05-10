note
	description: "{MEMORY_MANAGER_ACCESS} provides access to the central {MEMORY_MANAGER}."
	author: "Mischael Schill"
	date: "$Date: 2015-04-02 11:34:31 +0200 (Do, 02 Apr 2015) $"
	revision: "$Revision: 1145 $"

deferred class
	MEMORY_MANAGER_ACCESS

feature {NONE}
	manager: separate MEMORY_MANAGER
		once ("PROCESS")
			create Result
		end

	allocate_memory (a_count: INTEGER_32): separate MANAGED_POINTER
			-- Allocate some memory
		require
			a_count > 0
		do
			separate manager as m do
				Result := m.allocate_memory (a_count)
			end
		end

	retrieve_item (a_separate_area: separate MANAGED_POINTER): POINTER
		do
			Result := a_separate_area.item
		end

	own_memory (a_pointer: POINTER; a_count: INTEGER_32): separate MANAGED_POINTER
		require
			not a_pointer.is_default_pointer
			a_count > 0
		do
			separate manager as m do
				Result := m.own_memory (a_pointer, a_count)
			end
		end

end
