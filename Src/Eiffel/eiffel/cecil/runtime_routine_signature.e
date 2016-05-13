note
	description: "{RUNTIME_ROUTINE_SIGNATURE} contains the types of arguments and return values of a feature for introspection."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	RUNTIME_ROUTINE_SIGNATURE

inherit
	HASHABLE
		redefine
			is_equal
		end

	SHARED_WORKBENCH
		redefine
			is_equal
		end

create
	make

feature {NONE} -- Initialization
	make (a_feature: FEATURE_I; a_in_class: CLASS_TYPE)
		require
			feature_attached: attached a_feature
		local
			l_type: TYPE_A
		do
			in_class := a_in_class
			if a_feature.has_return_value then
				l_type := a_feature.type.adapted_in (a_in_class)
				if l_type.has_associated_class_type (a_in_class.type) then
					return_type := (l_type.annotation_flags & 0x00FF).bit_shift_left(16) + l_type.type_id (a_in_class.type) - 1
				else
					-- Open, reference generic variables end up here and are considered as "ANY". Maybe this could be improved?
					-- Is it possible to extract the actual generic parameter from the instance at runtime?
					return_type := (l_type.annotation_flags & 0x00FF).bit_shift_left(16)
				end
			else
				return_type := {NATURAL_16}.max_value
			end
			if a_feature.has_arguments then
				create argument_types.make (a_feature.argument_count)
				across
					a_feature.arguments as iter
				loop
					l_type := iter.item.adapted_in (a_in_class)
					if l_type.has_associated_class_type (a_in_class.type) then
						argument_types.extend ((l_type.annotation_flags & 0x00FF).bit_shift_left(16) + l_type.type_id (a_in_class.type) - 1)
					else
						argument_types.extend ((l_type.annotation_flags & 0x00FF).bit_shift_left(16))
					end
				end
			else
				create argument_types.make (0)
			end
			feat := a_feature
		end

feature -- Access
	feat: FEATURE_I
	in_class: CLASS_TYPE
	return_type: INTEGER_32
	argument_types: HASHABLE_ARRAYED_LIST [INTEGER]

feature -- Comparison
	is_equal (a_other: like Current): BOOLEAN
		do
			-- Equality is based on the generated type ids of return value and arguments, as well as
			-- whether the feature is an attribute, since this influences the SCOOP pattern
			Result := return_type = a_other.return_type and then
					argument_types ~ a_other.argument_types and then
					feat.is_attribute = a_other.feat.is_attribute
		end

feature -- Hash
	hash_code: INTEGER
		do
			Result := return_type + argument_types.hash_code
		end

feature -- Generation
	generate (a_buffer: GENERATION_BUFFER; a_is_final: BOOLEAN; a_id: INTEGER; a_patterns_table: SEPARATE_PATTERNS; a_arguments_cache: HASH_TABLE[INTEGER, HASHABLE_ARRAYED_LIST[INTEGER]])
			-- generate a struct with the type information to `a_buffer'
		require
			positive_id: a_id > 0
		local
			l_args_id: INTEGER
		do
			-- We reuse the same signatue arrays, for this we use a hash_table as a cache
			if attached a_arguments_cache[argument_types] as l_args and then l_args /= 0 then
				l_args_id := l_args
			else
				-- The signature is new, so we need to generate it and put it into the cache
				l_args_id := a_arguments_cache.count + 1
				a_arguments_cache[argument_types] := l_args_id
				a_buffer.put_formatted (once "static const EIF_ENCODED_TYPE eif_ce_args_$i[] = {", l_args_id)

				across
					argument_types as iter
				loop
					a_buffer.put_integer (iter.item)
					a_buffer.put_two_character (',', ' ')
				end
				a_buffer.put_hex_integer_16 ({NATURAL_16}.max_value)
				a_buffer.put_three_character ('}', ';', '%N')
			end

			a_buffer.put_formatted (once "static const struct eif_signature eif_ce_sig_$i = {", a_id)
			-- The scoop pattern is only generated in final mode with scoop enabled
			if a_is_final and system.is_scoop then
				if (feat = Void) or else feat.is_deferred then
					a_buffer.put_string (once "NULL")
				else
					a_buffer.put_character ('&')
					a_patterns_table.put_artificial (feat)
				end
				a_buffer.put_two_character (',', ' ')
			end
			-- The order in the struct is to first put in the pointers, then the rest
			a_buffer.put_formatted (once "eif_ce_args_$i, $i};%N", l_args_id, return_type)
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
