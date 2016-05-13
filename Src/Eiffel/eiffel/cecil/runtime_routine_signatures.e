note
	description: "{RUNTIME_ROUTINE_SIGNATURES} generates runtime information about result and argument types of routines."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	RUNTIME_ROUTINE_SIGNATURES

inherit
	SHARED_BYTE_CONTEXT
	SHARED_CODE_FILES
	SHARED_TYPE_I

create
	make

feature {NONE} -- Creation

	make (a_patterns_table: SEPARATE_PATTERNS)
			-- Initialize table. Routine information is put into `a_output_buffer'.
		do
			create infos.make (64)
			create arguments.make (32)
			next_id := 1
			patterns_table := a_patterns_table
		ensure
			patterns_table = a_patterns_table
			next_id = 1
		end

feature -- Access
	infos: HASH_TABLE [INTEGER, RUNTIME_ROUTINE_SIGNATURE]

	arguments: HASH_TABLE [INTEGER, HASHABLE_ARRAYED_LIST[INTEGER]]

	next_id: INTEGER

	buffer: detachable GENERATION_BUFFER
		-- The buffer where the type information is generated to

	patterns_table: SEPARATE_PATTERNS

feature -- Setting
	set_buffer (a_output_buffer: GENERATION_BUFFER)
		do
			buffer := a_output_buffer
		ensure
			buffer = a_output_buffer
		end

	wipe_out
			-- Discard already generated routine information structs
		do
			infos.wipe_out
			next_id := 1
		end

feature -- Generation

	put (a_feature: FEATURE_I; a_in_class: CLASS_TYPE; a_out: GENERATION_BUFFER; a_is_final: BOOLEAN)
			-- Generates, if necessary, a struct containing information about the given routine and prints the name of the struct to `a_out'.
		require
			buffer_attached: attached buffer
			feature_attached: attached a_feature
			out_attached: attached a_out
		local
			l_info: RUNTIME_ROUTINE_SIGNATURE
		do
			create l_info.make (a_feature, a_in_class)
			a_out.put_string (once "&eif_ce_sig_")
			if attached infos[l_info] as info_id and then info_id /= 0 then
				a_out.put_integer(info_id)
			else
				a_out.put_integer (next_id)
				l_info.generate (buffer, a_is_final, next_id, patterns_table, arguments)

				infos[l_info] := next_id
				next_id := next_id + 1
			end
		end

note
	copyright: "Copyright (c) 1984-2016, Eiffel Software"
	license: "GPL version 2 (see http://www.eiffel.com/licensing/gpl.txt)"
	licensing_options: "http://www.eiffel.com/licensing"
	copying: "[
			This file is part of Eiffel Software's Eiffel Development Environment.
			
			Eiffel Software's Eiffel Development Environment is free
			software; you can redistribute it and/or modify it under
			the terms of the GNU General Public License as published
			by the Free Software Foundation, version 2 of the License
			(available at the URL listed under "license" above).
			
			Eiffel Software's Eiffel Development Environment is
			distributed in the hope that it will be useful, but
			WITHOUT ANY WARRANTY; without even the implied warranty
			of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
			See the GNU General Public License for more details.
			
			You should have received a copy of the GNU General Public
			License along with Eiffel Software's Eiffel Development
			Environment; if not, write to the Free Software Foundation,
			Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
		]"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"
end
