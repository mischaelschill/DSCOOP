note
	description: "{EAREA} provides an immutable area of memory."
	author: "Mischael Schill"
	date: "$Date: 2015-04-02 11:34:31 +0200 (Do, 02 Apr 2015) $"
	revision: "$Revision: 1145 $"

expanded class
	EAREA

inherit
	PLATFORM
		export {NONE}
			copy
		redefine
			is_equal
		end

	MEMORY_MANAGER_ACCESS
		undefine
			is_equal, copy
		end

create
	default_create,
	copy_from_pointer,
	make_empty,
	merge

feature {NONE} -- Initialization
	copy_from_pointer (a_pointer: POINTER; a_length: INTEGER_32)
			-- Create a new area and copy data from `a_pointer'
		require
			a_length > 0
		local
			l_managed_pointer: separate MANAGED_POINTER
		do
			l_managed_pointer := allocate_memory (a_length)
			anchor := l_managed_pointer
			separate l_managed_pointer as mp do
				item := mp.item
			end
			item.memory_copy (a_pointer, a_length)
			count := a_length
		ensure
			count = a_length
			a_pointer.memory_compare (item, a_length)
		end

	own_from_pointer (a_pointer: POINTER; a_length: INTEGER_32)
			-- Create an area backed by `a_pointer'
		require
			a_length > 0
			not a_pointer.is_default_pointer
		local
			l_managed_pointer: separate MANAGED_POINTER
		do
			l_managed_pointer := own_memory (a_pointer, a_length)
			anchor := l_managed_pointer
			count := a_length
		ensure
			count = a_length
			a_pointer.memory_compare (item, a_length)
		end

	make_empty (a_length: INTEGER_32)
			-- Create a zeroed area
		require
			a_length > 0
		local
			l_managed_pointer: separate MANAGED_POINTER
		do
			l_managed_pointer := allocate_memory (a_length)
			anchor := l_managed_pointer
			item := retrieve_item (l_managed_pointer)
			count := a_length
		ensure
			count = a_length
		end

	merge (area_1: EAREA; start_1, count_1: INTEGER_32; area_2: EAREA; start_2, count_2: INTEGER_32)
		require
			start_1 >= 0
			count_1 >= 0
			start_1 + count_1 <= area_1.count

			start_2 >= 0
			count_2 >= 0
			start_2 + count_2 <= area_2.count
		do
			make_empty (count_1 + count_2)
			item.memory_copy (area_1.item + start_1, count_1)
			(item + count_1).memory_copy (area_1.item + start_2, count_2)
		ensure
			count = count_1 + count_2
		end

feature -- Access
	item: POINTER
		-- Pointer to position of area in memory

feature -- Status report
	count: INTEGER_32


feature -- Access: Platform specific

	read_natural_8 (pos: INTEGER): NATURAL_8
			-- Read NATURAL_8 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + natural_8_bytes) <= count
		do
			($Result).memory_copy (item + pos, natural_8_bytes)
		end

	read_natural_16 (pos: INTEGER): NATURAL_16
			-- Read NATURAL_16 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + natural_16_bytes) <= count
		do
			($Result).memory_copy (item + pos, natural_16_bytes)
		end

	read_natural_32 (pos: INTEGER): NATURAL_32
			-- Read NATURAL_32 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + natural_32_bytes) <= count
		do
			($Result).memory_copy (item + pos, natural_32_bytes)
		end

	read_natural_64 (pos: INTEGER): NATURAL_64
			-- Read NATURAL_64 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + natural_64_bytes) <= count
		do
			($Result).memory_copy (item + pos, natural_64_bytes)
		end

	read_integer_8 (pos: INTEGER): INTEGER_8
			-- Read INTEGER_8 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + integer_8_bytes) <= count
		do
			Result := read_natural_8 (pos).as_integer_8
		end

	read_integer_16 (pos: INTEGER): INTEGER_16
			-- Read INTEGER_16 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + integer_16_bytes) <= count
		do
			Result := read_natural_16 (pos).as_integer_16
		end

	read_integer_32 (pos: INTEGER): INTEGER
			-- Read INTEGER at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + integer_32_bytes) <= count
		do
			Result := read_natural_32 (pos).as_integer_32
		end

	read_integer_64 (pos: INTEGER): INTEGER_64
			-- Read INTEGER_64 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + integer_64_bytes) <= count
		do
			Result := read_natural_64 (pos).as_integer_64
		end

	read_pointer (pos: INTEGER): POINTER
			-- Read POINTER at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + Pointer_bytes) <= count
		do
			($Result).memory_copy (item + pos, Pointer_bytes)
		end

	read_boolean (pos: INTEGER): BOOLEAN
			-- Read BOOLEAN at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + Boolean_bytes) <= count
		do
			($Result).memory_copy (item + pos, Boolean_bytes)
		end

	read_character (pos: INTEGER): CHARACTER
			-- Read CHARACTER at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + Character_8_bytes) <= count
		do
			($Result).memory_copy (item + pos, Character_8_bytes)
		end

	read_real (pos: INTEGER): REAL
			-- Read REAL_32 at position `pos'.
		obsolete "Use read_real_32 instead."
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + Real_32_bytes) <= count
		do
			($Result).memory_copy (item + pos, Real_32_bytes)
		end

	read_real_32 (pos: INTEGER): REAL
			-- Read REAL_32 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + Real_32_bytes) <= count
		do
			($Result).memory_copy (item + pos, Real_32_bytes)
		end

	read_double (pos: INTEGER): DOUBLE
			-- Read REAL_64 at position `pos'.
		obsolete "Use read_real_64 instead."
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + Real_64_bytes) <= count
		do
			($Result).memory_copy (item + pos, Real_64_bytes)
		end

	read_real_64 (pos: INTEGER): DOUBLE
			-- Read REAL_64 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + Real_64_bytes) <= count
		do
			($Result).memory_copy (item + pos, Real_64_bytes)
		end

	read_array (pos, a_count: INTEGER): ARRAY [NATURAL_8]
			-- Read `count' bytes at position `pos'.
		require
			pos_nonnegative: pos >= 0
			count_positive: a_count > 0
			valid_position: (pos + a_count) <= count
		local
			i: INTEGER
			l_area: SPECIAL [NATURAL_8]
		do
			from
				create l_area.make_empty (a_count)
			until
				i >= a_count
			loop
				l_area.extend (read_natural_8 (pos + i))
				i := i + 1
			end
			create Result.make_from_special (l_area)
		ensure
			read_array_not_void: Result /= Void
			read_array_valid_count: Result.count = a_count
		end

feature -- Access: Little-endian format

	read_natural_8_le (pos: INTEGER): NATURAL_8
			-- Read NATURAL_8 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + natural_8_bytes) <= count
		do
			($Result).memory_copy (item + pos, natural_8_bytes)
		end

	read_natural_16_le (pos: INTEGER): NATURAL_16
			-- Read NATURAL_16 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + natural_16_bytes) <= count
		local
			l_high, l_low: NATURAL_16
		do
			if is_little_endian then
				Result := read_natural_16 (pos)
			else
				l_low := {NATURAL_16} 0x00FF & read_natural_8 (pos)
				l_high := read_natural_8 (pos + natural_8_bytes)
				Result := (l_high.to_natural_16 |<< 8) | l_low
			end
		end

	read_natural_32_le (pos: INTEGER): NATURAL_32
			-- Read NATURAL_32 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + natural_32_bytes) <= count
		local
			l_high, l_low: NATURAL_32
		do
			if is_little_endian then
				Result := read_natural_32 (pos)
			else
				l_low := {NATURAL_32} 0x0000FFFF & read_natural_16_le (pos)
				l_high := read_natural_16_le (pos + natural_16_bytes)
				Result := (l_high.to_natural_32 |<< 16) | l_low
			end
		end

	read_natural_64_le (pos: INTEGER): NATURAL_64
			-- Read NATURAL_64 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + natural_64_bytes) <= count
		local
			l_high, l_low: NATURAL_64
		do
			if is_little_endian then
				Result := read_natural_64 (pos)
			else
				l_low := {NATURAL_64} 0x00000000FFFFFFFF & read_natural_32_le (pos)
				l_high := read_natural_32_le (pos + natural_32_bytes)
				Result := (l_high.to_natural_64 |<< 32) | l_low
			end
		end

	read_integer_8_le (pos: INTEGER): INTEGER_8
			-- Read INTEGER_8 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + integer_8_bytes) <= count
		do
			Result := read_natural_8_le (pos).as_integer_8
		end

	read_integer_16_le (pos: INTEGER): INTEGER_16
			-- Read INTEGER_16 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + integer_16_bytes) <= count
		do
			Result := read_natural_16_le (pos).as_integer_16
		end

	read_integer_32_le (pos: INTEGER): INTEGER
			-- Read INTEGER at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + integer_32_bytes) <= count
		do
			Result := read_natural_32_le (pos).as_integer_32
		end

	read_integer_64_le (pos: INTEGER): INTEGER_64
			-- Read INTEGER_64 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + integer_64_bytes) <= count
		do
			Result := read_natural_64_le (pos).as_integer_64
		end

	read_real_32_le (pos: INTEGER): REAL
			-- Read REAL_32 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + real_32_bytes) <= count
		local
			l_nat32: NATURAL_32
		do
			check
				correct_size: real_32_bytes = natural_32_bytes
			end
			l_nat32 := read_natural_32_le (pos)
			($Result).memory_copy ($l_nat32, natural_32_bytes)
		end

	read_real_64_le (pos: INTEGER): DOUBLE
			-- Read REAL_64 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + real_64_bytes) <= count
		local
			l_nat64: NATURAL_64
		do
			check
				correct_size: real_64_bytes = natural_64_bytes
			end
			l_nat64 := read_natural_64_le (pos)
			($Result).memory_copy ($l_nat64, natural_64_bytes)
		end

feature -- Access: Big-endian format

	read_natural_8_be (pos: INTEGER): NATURAL_8
			-- Read NATURAL_8 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + natural_8_bytes) <= count
		do
			($Result).memory_copy (item + pos, natural_8_bytes)
		end

	read_natural_16_be (pos: INTEGER): NATURAL_16
			-- Read NATURAL_16 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + natural_16_bytes) <= count
		local
			l_high, l_low: NATURAL_16
		do
			if is_little_endian then
				l_high := read_natural_8 (pos)
				l_low := (0x00FF).to_natural_16 & read_natural_8 (pos + natural_8_bytes)
				Result := (l_high.to_natural_16 |<< 8) | l_low
			else
				Result := read_natural_16 (pos)
			end
		end

	read_natural_32_be (pos: INTEGER): NATURAL_32
			-- Read NATURAL_32 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + natural_32_bytes) <= count
		local
			l_high, l_low: NATURAL_32
		do
			if is_little_endian then
				l_high := read_natural_16_be (pos)
				l_low := (0x0000FFFF).to_natural_32 & read_natural_16_be (pos + natural_16_bytes)
				Result := (l_high.to_natural_32 |<< 16) | l_low
			else
				Result := read_natural_32 (pos)
			end
		end

	read_natural_64_be (pos: INTEGER): NATURAL_64
			-- Read NATURAL_64 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + natural_64_bytes) <= count
		local
			l_high, l_low: NATURAL_64
		do
			if is_little_endian then
				l_high := read_natural_32_be (pos)
				l_low := {NATURAL_64} 0x00000000FFFFFFFF & read_natural_32_be (pos + natural_32_bytes)
				Result := (l_high.to_natural_64 |<< 32) | l_low
			else
				Result := read_natural_64 (pos)
			end
		end

	read_integer_8_be (pos: INTEGER): INTEGER_8
			-- Read INTEGER_8 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + integer_8_bytes) <= count
		do
			Result := read_natural_8_be (pos).as_integer_8
		end

	read_integer_16_be (pos: INTEGER): INTEGER_16
			-- Read INTEGER_16 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + integer_16_bytes) <= count
		do
			Result := read_natural_16_be (pos).as_integer_16
		end

	read_integer_32_be (pos: INTEGER): INTEGER
			-- Read INTEGER at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + integer_32_bytes) <= count
		do
			Result := read_natural_32_be (pos).as_integer_32
		end

	read_integer_64_be (pos: INTEGER): INTEGER_64
			-- Read INTEGER_64 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + integer_64_bytes) <= count
		do
			Result := read_natural_64_be (pos).as_integer_64
		end

	read_real_32_be (pos: INTEGER): REAL
			-- Read REAL_32 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + real_32_bytes) <= count
		local
			l_nat32: NATURAL_32
		do
			check
				correct_size: real_32_bytes = natural_32_bytes
			end
			l_nat32 := read_natural_32_be (pos)
			($Result).memory_copy ($l_nat32, natural_32_bytes)
		end

	read_real_64_be (pos: INTEGER): DOUBLE
			-- Read REAL_64 at position `pos'.
		require
			pos_nonnegative: pos >= 0
			valid_position: (pos + real_64_bytes) <= count
		local
			l_nat64: NATURAL_64
		do
			check
				correct_size: real_64_bytes = natural_64_bytes
			end
			l_nat64 := read_natural_64_be (pos)
			($Result).memory_copy ($l_nat64, natural_64_bytes)
		end

feature -- Comparison
	is_equal (a_other: like Current): BOOLEAN
		do
			if a_other.item = item then
				Result := True
			elseif count = a_other.count then
				Result := a_other.item.memory_compare (a_other.item, count)
			end
		end

feature {EAREA} -- Internals
	anchor: detachable separate ANY

end
