indexing
	description: "Internal representation of class NATURAL"
	date: "$Date$"
	revision: "$Revision$"

class NATURAL_B 

inherit
	CLASS_B
		rename
			make as basic_make
		redefine
			actual_type
		end

create
	make
	
feature -- Initialization

	make (l: CLASS_I; n: INTEGER) is
			-- Creation of basic class
		require
			good_argument: l /= Void
			valid_n: n = 8 or n = 16 or n =32 or n = 64
		do
			basic_make (l)
			size := n
		ensure
			size_set: size = n
		end

feature -- Property

	size: INTEGER
			-- `size' in bits of current representation of INTEGER.

feature -- Access

	actual_type: NATURAL_A is
			-- Actual integer type
		do
			inspect size
			when 8 then Result := natural_8_type
			when 16 then Result := natural_16_type
			when 32 then Result := natural_32_type
			when 64 then Result := natural_64_type
			end
		end;

invariant
	correct_size: size = 8 or size = 16 or size = 32 or size = 64

end
