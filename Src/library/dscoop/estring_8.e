note
	description: "{ESTRING_8} is an expanded, immutable 8-bit string. It defaults to an empty string."
	author: "Mischael Schill"
	date: "$Date: 2015-06-12 09:55:48 +0200 (Fr, 12 Jun 2015) $"
	revision: "$Revision: 1810 $"

expanded class
	ESTRING_8

inherit
	EAREA
		rename
			make_empty as make_empty_area,
			item as area_item,
			count as area_count,
			merge as area_merge
		undefine
			out,
			is_equal
		redefine
			default_create,
			copy
		end

	READABLE_STRING_GENERAL
		rename
			item as item_32
		export {NONE}
			make,
			capacity,
			new_string,
			copy
		redefine
			valid_index,
			starts_with,
			is_equal,
			default_create,
			is_immutable,
			out,
			to_string_32,
			to_string_8,
			copy
		end

	READABLE_INDEXABLE[CHARACTER_8]
		undefine
			is_equal
		redefine
			default_create,
			out,
			copy
		end

create
	default_create,
	make_from_string_general,
	make_from_string_8,
	make_from_string_32,
	make_as_lower,
	make_as_upper,
	make_substring,
	make_from_c,
	merge_two,
	merge

create {ESTRING_8}
	copy_from_pointer,
	own_from_pointer

convert
	make_from_string_8 ({STRING_8}),
	make_from_string_32 ({STRING_32}),
	to_string_8: {STRING_8},
	to_string_32: {STRING_32},
	to_c_string: {C_STRING}

feature {NONE} -- Initialization
	default_create
		do

		end

	make (n: INTEGER)
		-- Not useful, therefore not implemented
		do
			check false end
		end

	make_from_separate (a_string: separate READABLE_STRING_GENERAL)
		require
			a_string.is_valid_as_string_8
		local
			i: INTEGER
			l_string: MANAGED_POINTER
		do
			create l_string.make (a_string.count + 1)
			from
				i := 1
			until
				i > a_string.count
			loop
				l_string.put_character (a_string[i].to_character_8, i - 1)
				i := i + 1
			end

			copy_from_pointer (l_string.item, l_string.count)
		end

	make_from_string_general,
	make_from_string_8,
	make_from_string_32 (a_string: READABLE_STRING_GENERAL)
		require
			a_string.is_valid_as_string_8
		local
			i: INTEGER
			l_string: MANAGED_POINTER
		do
			create l_string.make (a_string.count + 1)
			from
				i := 1
			until
				i > a_string.count
			loop
				l_string.put_character (a_string[i].to_character_8, i - 1)
				i := i + 1
			end

			copy_from_pointer (l_string.item, l_string.count)
		end

	make_substring (a_string: like Current; a_lower, a_upper: INTEGER)
		require
			a_lower <= a_upper + 1
			a_lower > 0
			a_upper <= a_string.count
			a_string.is_valid_as_string_8
		local
			i: INTEGER
			l_string: MANAGED_POINTER
		do
			create l_string.make (a_upper - a_lower + 2)

			from
				i := a_lower
			until
				i > a_upper
			loop
				l_string.put_character (a_string[i].to_character_8, i - a_lower)
				i := i + 1
			end

			copy_from_pointer (l_string.item, l_string.count)
		end

	make_as_lower (a_string: like Current)
		local
			i: INTEGER
			l_string: MANAGED_POINTER
		do
			create l_string.make (a_string.count + 1)

			from
				i := 1
			until
				i > a_string.count
			loop
				l_string.put_character (a_string[i].as_lower.to_character_8, i - 1)
				i := i + 1
			end

			copy_from_pointer (l_string.item, l_string.count)
		end

	make_as_upper (a_string: like Current)
		local
			i: INTEGER
			l_string: MANAGED_POINTER
		do
			create l_string.make (a_string.count + 1)

			from
				i := 1
			until
				i > a_string.count
			loop
				l_string.put_character (a_string[i].as_upper.to_character_8, i - 1)
				i := i + 1
			end

			copy_from_pointer (l_string.item, l_string.count)
		end

	make_from_c (a_pointer: POINTER)
		local
			l_mp: MANAGED_POINTER
			l_count: INTEGER_32
		do
			create l_mp.share_from_pointer (a_pointer, 2147483647)
			from
				l_count := 0
			until
				l_mp.read_natural_8 (l_count) = 0
			loop
				l_count := l_count + 1
			end
			if l_count > 0 then
				copy_from_pointer (l_mp.item, l_count + 1)
			end
		end

	merge (a_fragments: LIST[READABLE_STRING_GENERAL]; a_connector: READABLE_STRING_GENERAL)
		require
			across a_fragments as iter all iter.item.is_valid_as_string_8 end
		local
			l_buffer: MANAGED_POINTER
			l_string: READABLE_STRING_GENERAL
			i, j, k, n: INTEGER
		do
			-- Calculate the size of the string
			across
				a_fragments as iter
			loop
				n := n + iter.item.count
				n := n + a_connector.count
			end
			n := n - a_connector.count + 1

			if not a_fragments.is_empty then
				create l_buffer.make (n)
				from
					i := 1

					l_string := a_fragments[i]
					from
						j := 1
					until
						j > l_string.count
					loop
						l_buffer.put_character (l_string[j].to_character_8, k)
						k := k + 1
						j := j + 1
					end
					i := i + 1
				until
					i > a_fragments.count
				loop
					from
						j := 1
					until
						j > a_connector.count
					loop
						l_buffer.put_character (a_connector[j].to_character_8, k)
						k := k + 1
						j := j + 1
					end
					l_string := a_fragments[i]
					from
						j := 1
					until
						j > l_string.count
					loop
						l_buffer.put_character (l_string[j].to_character_8, k)
						k := k + 1
						j := j + 1
					end
					i := i + 1
				end
				l_buffer.put_natural_8 (0, k)
				check k = l_buffer.count - 1 end
				copy_from_pointer (l_buffer.item, l_buffer.count)
			else
				make_empty
			end
		end

	merge_two (a_string1, a_string2: like Current)
		do
			make_empty_area (a_string1.count + a_string2.count + 1)
			area_item.memory_copy (a_string1.area_item, a_string1.count)
			area_item.plus (a_string1.count).memory_copy (a_string2.area_item, a_string2.count)
		end

feature -- Access
	item alias "[]" (i: INTEGER): CHARACTER_8
		do
			Result := read_character (i - 1)
		end

	code (i: INTEGER): NATURAL_32
		do
			Result := item (i).code.as_natural_32
		end

feature -- Status report

	is_immutable: BOOLEAN
			-- Can the character sequence of `Current' be not changed?
		do
			Result := True
		end

	valid_code (v: NATURAL_32): BOOLEAN
			-- Is `v' a valid code for Current?
		do
			Result := v < 256
		end

	is_substring_whitespace (start_index, end_index: INTEGER): BOOLEAN
		local
			i: INTEGER_32
		do
			from
				i := start_index
				Result := True
			invariant
				Result implies across start_index |..| (i-1) as iter all item(iter.item).is_space end
				not Result implies across start_index |..| (i-1) as iter some not item(iter.item).is_space end
			until
				i > end_index or not Result
			loop
				if
					not item(i).is_space
				then
					Result := False
				end
				i := i + 1
			variant
				end_index + 1 - i
			end
		ensure then
				Result implies across start_index |..| end_index as iter all item(iter.item).is_space end
				not Result implies across start_index |..| end_index as iter some not item(iter.item).is_space end
		end

	is_string_32: BOOLEAN
			-- Is `Current' a sequence of CHARACTER_32?
		do
			Result := False
		end

	is_string_8: BOOLEAN
			-- Is `Current' a sequence of CHARACTER_8?
		do
			Result := True
		end

	is_valid_as_string_8: BOOLEAN
			-- Is `Current' convertible to a sequence of CHARACTER_8 without information loss?
		do
			Result := True
		end

	is_empty: BOOLEAN
			-- Is structure empty?
		do
			Result := count = 0
		end

	is_boolean: BOOLEAN
			-- Does `Current' represent a BOOLEAN?
		local
			l: like as_lower
		do
			l := as_lower
			Result := (l.is_equal("true") or
				l.is_equal("false"))
		end

	valid_index (i: INTEGER): BOOLEAN
			-- Is `i' a valid index?
		do
			Result := i > 0 and i <= count
		end

feature -- Measurement

	count: INTEGER
		do
			Result := (area_count - 1).max(0)
		end

	capacity: INTEGER
		do
			Result := count
		end

	lower: INTEGER
		do
			Result := 1
		end

	upper: INTEGER
		do
			Result := count
		end

feature -- Comparison

	substring_index_in_bounds (other: READABLE_STRING_GENERAL; start_pos, end_pos: INTEGER): INTEGER
			-- Position of first occurrence of `other' at or after `start_pos'
			-- and to or before `end_pos';
			-- 0 if none.
		local
			l_pos, l_other_pos, l_other_count: INTEGER
		do
			l_other_count := other.count
			from
				l_pos := start_pos
				Result := 0
				l_other_pos := 1
			until
				l_pos > end_pos or l_other_pos > l_other_count
			loop
				if item(l_pos) = other[l_other_pos] then
					if Result = 0 then
						Result := l_pos
					end
					l_other_pos := l_other_pos + 1
				else
					Result := 0
					l_other_pos := 1
				end
				l_pos := l_pos + 1
			end
			if l_other_pos <= l_other_count then
				Result := 0
			end
		end

	substring_index (other: READABLE_STRING_GENERAL; start_index: INTEGER): INTEGER
			-- Index of first occurrence of other at or after start_index;
			-- 0 if none
		do
			Result := substring_index_in_bounds (other, start_index, count)
		end

	is_less alias "<" (a_other: like Current): BOOLEAN
		local
			i: INTEGER
		do
			if not is_equal (a_other) then
				from
					i := 1
				until
					i > count or else i > a_other.count or else
						item (i) /= a_other.item (i)
				loop
					i := i + 1
				end

				if i > count and i > a_other.count then
					check count = a_other.count end
					Result := False
				elseif i > count then
					Result := True
				elseif i > a_other.count then
					Result := False
				else
					Result := item (i) < a_other.item (i)
				end
			end
		end

	is_equal (a_other: like Current): BOOLEAN
		local
			i: INTEGER
		do
			if count = a_other.count then
				from
					i := 1
				until
					i > count or else item (i) /= a_other.item (i)
				loop
					i := i + 1
				end

				if i > count then
					Result := True
				end
			end
		end

	starts_with (a_other: READABLE_STRING_GENERAL): BOOLEAN
		local
			i: INTEGER
		do
			Result := a_other.count <= count
			from
				i := 1
			until
				i > a_other.count or i > count or not Result
			loop
				Result := a_other[i] = item(i)
				i := i + 1
			end
		end

	fuzzy_index (other: READABLE_STRING_GENERAL; start: INTEGER; fuzz: INTEGER): INTEGER
			-- Position of first occurrence of `other' at or after `start'
			-- with 0..`fuzz' mismatches between the string and `other'.
			-- 0 if there are no fuzzy matches
		local
			l_outer_pos, l_pos, l_other_pos, l_count, l_fuzz_count, l_other_count: INTEGER
		do
			l_other_count := other.count
			l_count := count

			from
				l_outer_pos := start
			until
				l_outer_pos > l_count + l_other_count or Result > 0
			loop
				from
					l_pos := l_outer_pos
					Result := l_pos
					l_other_pos := 1
					l_fuzz_count := 0
				until
					l_pos > l_count or l_other_pos > l_other_count or Result = 0
				loop
					if item(l_pos) = other[l_other_pos] then
						l_other_pos := l_other_pos + 1
					else
						l_fuzz_count := l_fuzz_count + 1
						if l_fuzz_count > fuzz then
							Result := 0
						end
					end
					l_pos := l_pos + 1
				end

				if l_other_pos <= l_other_count then
					Result := 0
				end
				l_outer_pos := l_outer_pos + 1
			end
		end

feature -- Conversion

	as_lower: like Current
			-- New object with all letters in lower case.
		do
			create Result.make_as_lower (Current)
		end

	as_upper: like Current
			-- New object with all letters in upper case
		do
			create Result.make_as_upper (Current)
		end

	to_string_32: STRING_32
		local
			i: INTEGER
		do
			create Result.make (count)
			from
				i := 1
			until
				i > count
			loop
				Result.extend (item_32 (i))
				i := i + 1
			end
		end

	to_string_8: STRING_8
		local
			i: INTEGER
		do
			create Result.make (count)
			from
				i := 1
			until
				i > count
			loop
				Result.extend (item (i))
				i := i + 1
			end
		end

	to_c_string: C_STRING
		do
			create Result.make_by_pointer_and_count (area_item, count)
		end

	out: STRING_8
		do
			Result := to_string_8
		end

feature -- Element change

	plus alias "+" (s: like Current): like Current
		do
			create Result.merge_two (Current, s)
		end


	trim: ESTRING_8
		-- Returns a substring where all the leading and trailing whitespace is removed
		local
			s, e: INTEGER
			c: CHARACTER_8
		do
			if count = 0 then
				Result := Current
			elseif count = 1 then
				c := item (1)
				if not (c = ' ' or c = '%T' or c = '%N') then
					Result := Current
				end
			else
				c := item (1)
				if not (c = ' ' or c = '%T' or c = '%N' or c = '%R') then
					c := item (count)
					if not (c = ' ' or c = '%T' or c = '%N') then
						Result := Current
					end
				else
					from
						s := 1
						c := item (s)
					until
						s = count or not (c = ' ' or c = '%T' or c = '%N' or c = '%R')
					loop
						s := s + 1
						c := item (s)
					end
					from
						e := count
						c := item (e)
					until
						e = 1 or not (c = ' ' or c = '%T' or c = '%N' or c = '%R')
					loop
						e := e - 1
						c := item (e)
					end
					if e >= s then
						Result := substring (s, e)
					end
				end

			end
		end

	replace (a_char, a_replacement: CHARACTER_8): ESTRING_8
			-- Replace every occurence of `a_char' with `a_replacement'
		local
			i: INTEGER
			l_area: MANAGED_POINTER
			c: CHARACTER_8
		do
			if has (a_char) then
				from
					i := 1
					create l_area.make (count + 1)
				until
					i > count
				loop
					c := item (i)
					if c = a_char then
						l_area.put_character (a_replacement, i - 1)
					else
						l_area.put_character (c, i - 1)
					end
					i := i + 1
				end
				create Result.copy_from_pointer (l_area.item, count + 1)
			else
				Result := Current
			end
		end

feature -- Duplication

	substring (start_index, end_index: INTEGER): like Current
			-- Copy of substring containing all characters at indices
			-- between `start_index' and `end_index'
		do
			create Result.make_substring(Current, start_index.max (1), end_index.min (count))
		end

feature {NONE}
	copy (other: like Current)
		do
			area_item := other.area_item
			area_count := other.area_count
			anchor := other.anchor
		end

feature {ESTRING_8} -- Implementation
	new_string (n: INTEGER): like Current
			-- Not useful, not implemented
		do
		end

	string_searcher: ESTRING_SEARCHER
			-- Facilities to search string in another string.
		do
			create Result.make
		end

	item_32 (i: INTEGER): CHARACTER_32
		do
			Result := item (i).to_character_32
		end
end
