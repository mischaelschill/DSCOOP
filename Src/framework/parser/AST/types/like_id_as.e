indexing
	description: "Abstract description for `like id' type. Version for Bench."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	LIKE_ID_AS

inherit
	TYPE_AS
		redefine
			first_token, last_token
		end

create
	initialize

feature {NONE} -- Initialization

	initialize (a: like anchor; l_as: like like_keyword; m_as: like attachment_mark) is
			-- Create a new LIKE_ID AST node.
		require
			a_not_void: a /= Void
		do
			anchor := a
			like_keyword := l_as
			attachment_mark := m_as
		ensure
			anchor_set: anchor = a
			like_keyword_set: like_keyword = l_as
			attachment_mark_set: attachment_mark = m_as
		end

feature -- Visitor

	process (v: AST_VISITOR) is
			-- process current element.
		do
			v.process_like_id_as (Current)
		end

feature -- Roundtrip

	attachment_mark: SYMBOL_AS
			-- Attachment symbol (if any)

	like_keyword: KEYWORD_AS
		-- Keyword "like" associated with this structure

feature -- Attributes

	anchor: ID_AS
			-- Anchor name

feature -- Roundtrip/Token

	first_token (a_list: LEAF_AS_LIST): LEAF_AS is
		do
			Result := Precursor (a_list)
			if Result = Void then
				if a_list = Void then
					Result := anchor.first_token (a_list)
				elseif attachment_mark /= Void then
					Result := attachment_mark.first_token (a_list)
				else
					Result := like_keyword.first_token (a_list)
				end
			end
		end

	last_token (a_list: LEAF_AS_LIST): LEAF_AS is
		do
			Result := Precursor (a_list)
			if Result = Void then
				Result := anchor.last_token (a_list)
			end
		end

feature -- Comparison

	is_equivalent (other: like Current): BOOLEAN is
			-- Is `other' equivalent to the current object ?
		do
			if attachment_mark = Void then
				Result := other.attachment_mark = Void
			elseif other.attachment_mark /= Void then
				Result := attachment_mark.is_equivalent (other.attachment_mark)
			end
			if Result then
				Result := equivalent (anchor, other.anchor)
			end
		end

feature -- Output

	dump: STRING is
			-- Dump string
		do
			create Result.make (7 + anchor.name.count)
			if attachment_mark /= Void then
				if attachment_mark.is_bang then
					Result.append_character ('!')
				else
					Result.append_character ('?')
				end
				Result.append_character (' ')
			end
			Result.append ("like ")
			Result.append (anchor.name)
		end

feature {LIKE_ID_AS} -- Replication

	set_anchor (a: like anchor) is
		do
			anchor := a
		end

indexing
	copyright:	"Copyright (c) 1984-2007, Eiffel Software"
	license:	"GPL version 2 (see http://www.eiffel.com/licensing/gpl.txt)"
	licensing_options:	"http://www.eiffel.com/licensing"
	copying: "[
			This file is part of Eiffel Software's Eiffel Development Environment.
			
			Eiffel Software's Eiffel Development Environment is free
			software; you can redistribute it and/or modify it under
			the terms of the GNU General Public License as published
			by the Free Software Foundation, version 2 of the License
			(available at the URL listed under "license" above).
			
			Eiffel Software's Eiffel Development Environment is
			distributed in the hope that it will be useful,	but
			WITHOUT ANY WARRANTY; without even the implied warranty
			of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
			See the	GNU General Public License for more details.
			
			You should have received a copy of the GNU General Public
			License along with Eiffel Software's Eiffel Development
			Environment; if not, write to the Free Software Foundation,
			Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA
		]"
	source: "[
			 Eiffel Software
			 356 Storke Road, Goleta, CA 93117 USA
			 Telephone 805-685-1006, Fax 805-685-6869
			 Website http://www.eiffel.com
			 Customer support http://support.eiffel.com
		]"

end -- class LIKE_ID_AS
