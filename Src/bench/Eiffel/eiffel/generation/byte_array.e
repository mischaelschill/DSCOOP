indexing
	description: "Byte array for generating melted code"
	date: "$Date$"
	revision: "$Revision$"

class BYTE_ARRAY

inherit
	CHARACTER_ARRAY
		rename
			make as basic_make
		end
	PLATFORM
		export
			{NONE} all
		end
	SHARED_C_LEVEL
		export
			{NONE} all
		end
	BYTE_CONST
		export
			{NONE} all
		end

	REFACTORING_HELPER
		export
			{NONE} fixme
		end

create
	make

feature {NONE} -- Initialization

	make is
			-- Initialization
		do
			basic_make (Chunk)
			position := 0
			create forward_marks.make (Jump_stack_size)
			create forward_marks2.make (Jump_stack_size)
			create forward_marks3.make (Jump_stack_size)
			create forward_marks4.make (Jump_stack_size)
			create backward_marks.make (Jump_stack_size)
		end

feature -- Access

	last_string: STRING
			-- Last string read by `last_string'.

	last_long_integer: INTEGER
			-- Last long integer read by `read_long_integer'.

	last_short_integer: INTEGER
			-- Last short integer read by `read_short_integer'.

	Chunk: INTEGER is 5000
			-- Chunk array

	Jump_stack_size: INTEGER is 50
			-- Initial size of stack recording jump in generated byte code.

feature -- Removal

	clear is
			-- Clear the structure
		do
			position := 0
			last_string := Void
			last_long_integer := 0
			last_short_integer := 0
			retry_position := 0
			area.clear_all
		end

feature --

	character_array: CHARACTER_ARRAY is
			-- Simple character array
		local
			other_area: like area
		do
			create Result.make (position)
			other_area := Result.area
			internal_copy (area, other_area, position, 0)
		end

	feature_table: MELTED_FEATURE_TABLE is
			-- Melted feature table
		local
			other_area: like area
		do
			create Result.make (position)
			other_area := Result.area
			internal_copy (area, other_area, position, 0)
		end

	melted_feature: MELT_FEATURE is
			-- Melted feature
		local
			other_area: like area
		do
			create Result.make (position)
			other_area := Result.area
			internal_copy (area, other_area, position, 0)
		end

	melted_descriptor: MELTED_DESC is
			-- Melted descriptor
		local
			other_area: like area
		do
			create Result.make (position)
			other_area := Result.area
			internal_copy (area, other_area, position, 0)
		end

	melted_routine_table: MELTED_ROUT_TABLE is
			-- Melted routine table
		local
			other_area: like area
		do
			create Result.make (position)
			other_area := Result.area
			internal_copy (area, other_area, position, 0)
		end

	melted_routid_array: MELTED_ROUTID_ARRAY is
			-- Melted routine id array
		local
			other_area: like area
		do
			create Result.make (position)
			other_area := Result.area
			internal_copy (area, other_area, position, 0)
		end

feature -- Element change

	append (c: CHARACTER) is
			-- Append `c' in the array
		local
			new_position: INTEGER
		do
			new_position := position + 1
			if new_position >= count then
				resize (count + Chunk)
			end
			area.put (c, position)
			position := new_position
		end

	append_boolean (b: BOOLEAN) is
			-- Append boolean `b' in array.
		do
			if b then
				append ('%/001/')
			else
				append ('%U')
			end
		end

	append_natural_8 (i: INTEGER_8) is
			-- Append natural `i' in the array
		local
			new_position: INTEGER
		do
			fixme ("Use NATURAL_XX types after compiler bootstrap")
			new_position := position + natural_8_bytes
			if new_position >= count then
				resize (count + Chunk)
			end
			($area + position).memory_copy ($i, natural_8_bytes)
			position := new_position
		end

	append_natural_16 (i: INTEGER_16) is
			-- Append natural `i' in the array
		local
			new_position: INTEGER
		do
			fixme ("Use NATURAL_XX types after compiler bootstrap")
			new_position := position + natural_16_bytes
			if new_position >= count then
				resize (count + Chunk)
			end
			($area + position).memory_copy ($i, natural_16_bytes)
			position := new_position
		end

	append_natural_32 (i: INTEGER) is
			-- Append unsigned 32 bits natural in the array
		local
			new_position: INTEGER
		do
			fixme ("Use NATURAL_XX types after compiler bootstrap")
			new_position := position + natural_32_bytes
			if new_position >= count then
				resize (count + Chunk)
			end
			($area + position).memory_copy ($i, natural_32_bytes)
			position := new_position
		end

	append_natural_64 (i: INTEGER_64) is
			-- Append long natural `i' in the array
		local
			new_position: INTEGER
		do
			fixme ("Use NATURAL_XX types after compiler bootstrap")
			new_position := position + natural_64_bytes
			if new_position >= count then
				resize (count + Chunk)
			end
			($area + position).memory_copy ($i, natural_64_bytes)
			position := new_position
		end

	append_integer_8 (i: INTEGER_8) is
			-- Append integer `i' in the array
		local
			new_position: INTEGER
		do
			new_position := position + integer_8_bytes
			if new_position >= count then
				resize (count + Chunk)
			end
			($area + position).memory_copy ($i, integer_8_bytes)
			position := new_position
		end

	append_integer_16 (i: INTEGER_16) is
			-- Append integer `i' in the array
		local
			new_position: INTEGER
		do
			new_position := position + integer_16_bytes
			if new_position >= count then
				resize (count + Chunk)
			end
			($area + position).memory_copy ($i, integer_16_bytes)
			position := new_position
		end

	append_integer (i: INTEGER) is
			-- Append `i' in the array
		do
			fixme ("Should we update callers to use `append_integer_32' ?")
			append_integer_32 (i)
		end
		
	append_integer_32 (i: INTEGER) is
			-- Append long integer `i' in the array
		local
			new_position: INTEGER
		do
			new_position := position + integer_32_bytes
			if new_position >= count then
				resize (count + Chunk)
			end
			($area + position).memory_copy ($i, integer_32_bytes)
			position := new_position
		end

	append_integer_64 (i: INTEGER_64) is
			-- Append long integer `i' in the array
		local
			new_position: INTEGER
		do
			new_position := position + integer_64_bytes
			if new_position >= count then
				resize (count + Chunk)
			end
			($area + position).memory_copy ($i, integer_64_bytes)
			position := new_position
		end

	append_short_integer (i: INTEGER) is
			-- Append short integer `i' in the array
		require
			valid_short_integer: i >= feature {INTEGER_16}.Min_value and
				i <= feature {INTEGER_16}.Max_value
		do
			fixme ("[
				Callers should verify that they actually don't mean to
				use `append_natural_16' use NATURAL_16.
				]")
			append_integer_16 (i.to_integer_16)
		end

	append_uint32_integer (i: INTEGER) is
			-- Append integer `i' in the array
		require
			valid_uint32_integer: i >= 0
		do
			fixme ("[
				Callers should verify that they actually don't mean to
				use `append_natural_32' use NATURAL_32.
				]")
			append_integer_32 (i)
		end

	append_double (d: DOUBLE) is
			-- Append real value `d'.
		local
			new_position: INTEGER
		do
			new_position := position + real_64_bytes
			if new_position >= count then
				resize (count + Chunk)
			end
			($area + position).memory_copy ($d, real_64_bytes)
			position := new_position
		end

	append_string (s: STRING) is
			-- Append string `s'.
		require
			good_argument: s /= Void
		local
			i, nb: INTEGER
		do
			from
				i := 1
				nb := s.count
					-- First write the string count
				append_short_integer (nb)
			until
				i > nb
			loop
				append (s.item (i))
				i := i + 1
			end
		end

	append_bit (s: STRING) is
			-- Append bit which string value is `s'.
		local
			nb_uint32, new_position, bcount: INTEGER
			ptr: ANY
		do
				-- Append number of uint32 integers needed
				-- for representing the bit value `s'
			bcount := s.count
			append_uint32_integer (bcount)

				-- Resize if necessary
			nb_uint32 := ca_bsize(bcount)
			new_position := position + nb_uint32 * natural_32_bytes
			if new_position >= count then
				resize ((new_position \\ Chunk + 1) * Chunk)
			end
				
				-- Write bit representation in `area'
			ptr := s.to_c
			ca_wbit ($area, $ptr, position, s.count)
			position := new_position
		end

	append_raw_string (s: STRING) is
			-- Append string `s'.
		require
			good_argument: s /= Void
		local
			i, nb: INTEGER
		do
			from
				i := 1
				nb := s.count
			until
				i > nb
			loop
				append (s.item (i))
				i := i + 1
			end
			append ('%U')
		end

	allocate_space (t: TYPE_I) is
			-- Allocate space for meta-type `t'.
		require
			good_argument: t /= Void
		local
			new_position: INTEGER
		do
			inspect
				t.c_type.level
			when C_char then
				new_position := position + character_bytes
			when c_uint8 then
				new_position := position + natural_8_bytes
			when c_uint16 then
				new_position := position + natural_16_bytes
			when c_uint32 then
				new_position := position + natural_32_bytes
			when c_uint64 then
				new_position := position + natural_64_bytes
			when C_int8 then
				new_position := position + integer_8_bytes
			when C_int16, C_wide_char then
				new_position := position + integer_16_bytes
			when C_int32 then
				new_position := position + integer_32_bytes
			when C_int64 then
				new_position := position + integer_64_bytes
			when C_real32 then
				new_position := position + real_32_bytes
			when C_real64 then
				new_position := position + real_64_bytes
			when C_pointer, C_ref then
				new_position := position + pointer_bytes
			else
					-- Void type
				new_position := position
			end
			if new_position >= count then
				resize (count + Chunk)
			end
			position := new_position
		end

feature -- Forward and backward jump managment

	forward_marks: ARRAYED_STACK [INTEGER]
			-- Forward jump stack

	mark_forward is
			-- Mark a forward offset
		do
			forward_marks.put (position)
			append_integer_32 (0)
		end

	write_forward is
			-- Write Current position at previous mark
		local
			pos: INTEGER
		do
			pos := position
			position := forward_marks.item
			forward_marks.remove
			append_integer_32 (pos - position - integer_32_bytes)
			position := pos
		end

	forward_marks2: ARRAYED_STACK [INTEGER]
			-- Forward jump stack
	
	mark_forward2 is
			-- Mark a forward offset
		do
			forward_marks2.put (position)
			append_integer_32 (0)
		end

	write_forward2 is
			-- Write Current position at previous mark
		local
			pos: INTEGER
		do
			pos := position
			position := forward_marks2.item
			forward_marks2.remove
			append_integer_32 (pos - position - integer_32_bytes)
			position := pos
		end

	forward_marks3: ARRAYED_STACK [INTEGER]
			-- Forward jump stack

	mark_forward3 is
			-- Mark a forward offset
		do
			forward_marks3.put (position)
			append_integer_32 (0)
		end

	write_forward3 is
			-- Write Current position at previous mark
		local
			pos: INTEGER
		do
			pos := position
			position := forward_marks3.item
			forward_marks3.remove
			append_integer_32 (pos - position - integer_32_bytes)
			position := pos
		end

	forward_marks4: ARRAYED_STACK [INTEGER]
			-- Forward jump stack

	mark_forward4 is
			-- Mark a forward offset
		do
			forward_marks4.put (position)
			append_integer_32 (0)
		end

	write_forward4 is
			-- Write Current position at previous mark
		local
			pos: INTEGER
		do
			pos := position
			position := forward_marks4.item
			forward_marks4.remove
			append_integer_32 (pos - position - integer_32_bytes)
			position := pos
		end

	backward_marks: ARRAYED_STACK [INTEGER]
			-- Backward jump stack

	mark_backward is
			-- Mark a backward offset
		do
			backward_marks.put (position)
		end

	write_backward is
			-- Write a backward jump
		do
			append_integer_32 (- position - integer_32_bytes + backward_marks.item)
			backward_marks.remove
		end

	retry_position: INTEGER
			-- Retry position

	mark_retry is
			-- Record retry position
		do
			retry_position := position
		end

	write_retry is
			-- Write a retry offset
		do
			append_integer_32 (- position - integer_32_bytes + retry_position)
		end

	prepend (other: BYTE_ARRAY) is
			-- Prepend `other' before in Current
		local
			new_size, old_pos, new_pos, other_position: INTEGER
			other_area, buffer_area: like area
		do
			old_pos := position
			other_position := other.position
			if old_pos >= Buffer.count then
				new_size := Chunk * (1 + (old_pos // Chunk))
				Buffer.resize (new_size)
			end
			buffer_area := Buffer.area
			internal_copy (area, buffer_area, old_pos, 0)
			new_pos := old_pos + other_position
			if new_pos >= count then
				new_size := Chunk * (1 + (new_pos // Chunk))
				resize (new_size)
			end
			other_area := other.area
			internal_copy (other_area, area, other_position, 0)
			internal_copy (buffer_area, area, old_pos, other_position)
			position := new_pos
		end

	Buffer: BYTE_ARRAY is
			-- Prepend buffer
		once
			create Result.make
		end

feature -- Debugger

	generate_melted_debugger_hook(lnr: INTEGER) is
			-- Write continue mark (where breakpoint may be set).
			-- lnr is the current breakable line number index.
		do
			append (Bc_hook)
			append_integer_32 (lnr)
		end

	generate_melted_debugger_hook_nested(lnr: INTEGER) is
			-- Write continue mark (where breakpoint may be set).
			-- lnr is the current breakable line number index (nested call).
		do
			append (Bc_nhook)
			append_integer_32 (lnr)
		end

feature {BYTE_ARRAY} -- Access

	position: INTEGER
			-- Position of the cursor in the array

feature {NONE} -- Externals

	ca_bsize (bit_count: INTEGER): INTEGER is
			-- Number of uint32 fields for encoding a bit of length `bit_count'
		external
			"C [macro %"eif_eiffel.h%"] (long int): EIF_INTEGER"
		alias
			"BIT_NBPACK"
		end

	ca_wbit(ptr: POINTER; val: POINTER; pos: INTEGER; bit_count: INTEGER) is
			-- Write in `ptr' at position `pos' a bit value `val'
		external
			"C"
		end

invariant
	position_greater_than_zero: position >= 0
	position_less_than_size: position < count
	integer_32_valid: integer_32_bytes = natural_32_bytes

end
