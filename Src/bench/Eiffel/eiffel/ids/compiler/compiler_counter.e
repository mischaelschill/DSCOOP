deferred class COMPILER_COUNTER

inherit

	HASH_TABLE [COMPILER_SUBCOUNTER, INTEGER]
		rename
			make as ht_make,
			item as ht_item
		end;
	HASH_TABLE [COMPILER_SUBCOUNTER, INTEGER]
		rename
			make as ht_make
		redefine
			item 
		select
			item
		end;
	SHARED_WORKBENCH
		undefine
			is_equal, copy, consistent, setup
		end;
	COMPILER_EXPORTER
		undefine
			is_equal, copy, setup, consistent
		end

feature -- Initialization

	make is
			-- Create a new counter.
		local
			compilation_id: INTEGER
		do
			ht_make (Initial_size);
			compilation_id := System.compilation_id;
			current_subcounter := new_subcounter (compilation_id);
			put (current_subcounter, compilation_id)
		end

	init_counter is
			-- Renumber ids already generated so far and continue
			-- generation from there.
		local
			nb, compilation_id: INTEGER
		do
			nb := current_subcounter.offset + current_subcounter.count
			compilation_id := System.compilation_id;
			current_subcounter := new_subcounter (compilation_id);
			current_subcounter.set_offset (nb);
			put (current_subcounter, compilation_id)
		end

	new_subcounter (compilation_id: INTEGER): COMPILER_SUBCOUNTER is
			-- New subcounter associated with `compilation_id'
		deferred
		ensure
			new_subcounter_not_void: Result /= Void
		end

	append (other: like Current) is
			-- Append ids generated by `other' to `Current' and
			-- renumber the resulting set of ids.
		require
			other_not_void: other /= Void
		local
			counter: COMPILER_SUBCOUNTER;
			nb, compilation_id: INTEGER
		do
			nb := current_subcounter.offset;
			from other.start until other.after loop
				compilation_id := other.key_for_iteration;
				if not has (compilation_id) then
					counter := other.item_for_iteration;
					counter.set_offset (nb);
					nb := nb + counter.count;
					put (counter, compilation_id)
				end;
				other.forth
			end;
			current_subcounter.set_offset (nb)
		end

feature -- Access

	next_id: COMPILER_ID is
			-- Next id
		do
			Result := current_subcounter.next_id
		ensure
			id_not_void: Result /= Void
		end

	item (i: INTEGER): like current_subcounter is
			-- Subcounter associted with compilation `i'
		do
			Result ?= ht_item (i)
		end

	current_count: INTEGER is
			-- Number of ids generated during the current compilation unit
			-- (i.e. do not count precompiled ids when the system relies on
			-- precompiled library)
		do
			Result := current_subcounter.count
		end
 
	total_count: INTEGER is
			-- Total number of ids generated
		do
			Result := current_subcounter.offset + current_subcounter.count
		end

feature {NONE} -- Implementation

	current_subcounter: COMPILER_SUBCOUNTER;
			-- Current subcounter

	Initial_size: INTEGER is 5;
			-- Hash table initial size

invariant

	current_subcounter_not_void: current_subcounter /= Void

end -- class COMPILER_COUNTER
