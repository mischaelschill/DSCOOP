indexing
	description: "Abstract description of one or more Eiffel new-line characters"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	NEW_LINE_AS

inherit
	LEAF_AS
		redefine
			text
		end

create
	make, make_with_data

feature -- Initialization

	make (a_scn: EIFFEL_SCANNER) is
			-- Create an new-line object with information included in `a_scn'.
		require
			a_scn_not_void: a_scn /= Void
		do
			make_with_location (a_scn.line, a_scn.column, a_scn.position, 1)
		end

	make_with_data (a_text: STRING; l, c, p, s: INTEGER) is
			-- Create an new-line object with `a_text' as literal text of new-line characters in source code.
			-- `l', `c', `p', `s' are positions. See `make_with_location' for more information.
		require
			a_text_not_void: a_text /= Void
			a_text_not_empty: not a_text.is_empty
		do
			make_with_location (l, c, p, s)
		end

feature -- Access

	number_of_breakpoint_slots: INTEGER is
		do
		end

	text (a_list: LEAF_AS_LIST): STRING is
			-- Literal text of this token
		do
			Result := "%N"
		end

feature -- Visitor

	process (v: AST_VISITOR) is
		do
			v.process_new_line_as (Current)
		end

feature -- Comparison

	is_equivalent (other: like Current): BOOLEAN is
		do
			Result := is_equal (other)
		end

end
