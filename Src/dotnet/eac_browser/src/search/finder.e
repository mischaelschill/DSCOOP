note
	description: "[
					Find features names in EAC
				]"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	FINDER

inherit
	CACHE
	
feature -- Access

	find_eiffel_type_name (an_eiffel_type_name: STRING): LINKED_LIST [SPECIFIC_TYPE]
			-- Return the list of `full_dotnet_type_name' corresponding to `an_eiffel_type_name'.
		require
			non_void_eiffel_type_name: an_eiffel_type_name /= Void
			no_empty_eiffel_type_name: not an_eiffel_type_name.is_empty
		local
			i: INTEGER
			eac: EAC_BROWSER
			ca: CACHE_INFO
			l_type: SPECIFIC_TYPE
		do
			create eac
			ca := eac.info
			from
				i := 1
				create Result.make
			until
				i > ca.assemblies.count
			loop
				l_type := find_eiffel_type_name_in_assembly (ca.assemblies.item (i), an_eiffel_type_name)
				if l_type /= Void then
					Result.extend (l_type)
				end
				i := i + 1
			end
		ensure
			non_void_result: Result /= Void
		end

	find_eiffel_type_name_in_assembly (an_assembly: CONSUMED_ASSEMBLY; an_eiffel_type_name: STRING): SPECIFIC_TYPE
			-- Return the `full_dotnet_type_name' corresponding to `an_eiffel_type_name'.
		require
			non_void_assembly: an_assembly /= Void
			non_void_eiffel_type_name: an_eiffel_type_name /= Void
			no_empty_eiffel_type_name: not an_eiffel_type_name.is_empty
		local
			i: INTEGER
			eac: EAC_BROWSER
			cat: CONSUMED_ASSEMBLY_TYPES
			ct: CONSUMED_TYPE
		do
			create eac
			cat := eac.consumed_assembly (an_assembly)
			from
				i := 1
			until
				i > cat.eiffel_names.count or Result /= Void
			loop
				if cat.eiffel_names.item (i).is_equal (an_eiffel_type_name) then
					ct := eac.consumed_type (an_assembly, cat.dotnet_names.item (i))
					create Result.make (an_assembly, ct)
				end
					-- add type in cache
--				if not cache.Types.has (full_dotnet_type_name) then
--					cache.Types.extend (cat.eiffel_names.item (i), full_dotnet_type_name)
--				end
				i := i + 1
			end
		end


	find_eiffel_feature_name_in_assembly (an_assembly: CONSUMED_ASSEMBLY; an_eiffel_feature_name: STRING): STRING
			-- Return the `dotnet_feature_name' corresponding to `an_eiffel_feature_name'.
		require
			non_void_assembly: an_assembly /= Void
			non_void_eiffel_feature_name: an_eiffel_feature_name /= Void
			no_empty_eiffel_feature_name: not an_eiffel_feature_name.is_empty
		local
			i: INTEGER
			eac: EAC_BROWSER
			cat: CONSUMED_ASSEMBLY_TYPES
			full_dotnet_type_name: STRING
		do
			create eac
			cat := eac.consumed_assembly (an_assembly)
			from
				i := 1
			until
				i > cat.dotnet_names.count or Result /= Void
			loop
				full_dotnet_type_name := cat.dotnet_names.item (i)
				Result := find_eiffel_feature_name_in_type (an_assembly, full_dotnet_type_name, an_eiffel_feature_name)					-- add type in cache
--				if not cache.Types.has (full_dotnet_type_name) then
--					cache.Types.extend (cat.eiffel_names.item (i), full_dotnet_type_name)
--				end
				i := i + 1
			end
			
			if result /= Void then
				Result := full_dotnet_type_name + ": " + Result
			end
		end

	find_eiffel_feature_name_in_type (an_assembly: CONSUMED_ASSEMBLY; a_dotnet_type_name: STRING; an_eiffel_feature_name: STRING): STRING
			-- Return the `dotnet_feature_name' corresponding to `an_eiffel_feature_name'.
		require
			non_void_assembly: an_assembly /= Void
			non_void_dotnet_type_name: a_dotnet_type_name /= Void
			no_empty_dotnet_type_name: not a_dotnet_type_name.is_empty
			non_void_eiffel_feature_name: an_eiffel_feature_name /= Void
			no_empty_eiffel_feature_name: not an_eiffel_feature_name.is_empty
		local
			i: INTEGER
			eac: EAC_BROWSER
			l_type: CONSUMED_TYPE
		do
			create eac
			l_type := eac.consumed_type (an_assembly, a_dotnet_type_name)
			if l_type /= Void then
				from
					i := 1
				until
					i > l_type.constructors.count or Result /= Void
				loop
					if an_eiffel_feature_name.is_equal (l_type.constructors.item (i).eiffel_name) then
						Result := l_type.constructors.item (i).Dotnet_name
					end
					i := i + 1
				end
				if Result = Void then
					Result := search_in_array (l_type.fields, an_eiffel_feature_name)
					if Result = Void then
						Result := search_in_array (l_type.functions, an_eiffel_feature_name)
						if Result = Void then
							Result := search_in_array (l_type.procedures, an_eiffel_feature_name)
						end
					end
				end
			end
			
--			if Result = Void then
--				Result := an_assembly.name + " do not contain feature " + an_eiffel_feature_name
--			end
--		ensure
--			non_void_result: Result /= Void
		end

feature {NONE} --Implementation

	search_in_array (array: ARRAY [CONSUMED_MEMBER]; an_eiffel_feature_name: STRING): STRING
			-- search `an_eiffel_feature_name' in `array'.
		require
			non_void_array: array /= Void
			non_void_an_eiffel_feature_name: an_eiffel_feature_name /= Void
			non_empty_an_eiffel_feature_name: not an_eiffel_feature_name.is_empty
		local
			i: INTEGER
		do
			from
				i := 1
			until
				i > array.count or Result /= Void
			loop
				if array.item (i).eiffel_name.is_equal (an_eiffel_feature_name) then
					Result := array.item (i).dotnet_name
				end
				i := i + 1
			end
		end

feature -- Name

	eiffel_type_name (an_assembly: CONSUMED_ASSEMBLY; a_full_dotnet_type_name: STRING): STRING
			-- Return the `eiffel_type_name' corresponding to `a_dotnet_type_name'.
			-- | Check if `a_full_dotnet_type_name' is in `types'. If not call `search_eiffel_type_name'.
		require
			non_void_assembly: an_assembly /= Void
			non_void_a_full_dotnet_type_name: a_full_dotnet_type_name /= Void
			not_empty_a_full_dotnet_type_name: not a_full_dotnet_type_name.is_empty
		do
			if types.has (a_full_dotnet_type_name) then
				Result := types.item (a_full_dotnet_type_name)
			else
				Result := search_eiffel_type_name (an_assembly, a_full_dotnet_type_name)
			end
		ensure
			non_void_result: Result /= Void
		end
	
	search_eiffel_type_name (an_assembly: CONSUMED_ASSEMBLY; a_dotnet_type_name: STRING): STRING
			-- Return the `eiffel_type_name' corresponding to `a_dotnet_type_name'.
		require
			non_void_an_assembly: an_assembly /= Void
			non_void_a_dotnet_type_name: a_dotnet_type_name /= Void
			not_empty_a_dotnet_type_name: not a_dotnet_type_name.is_empty
		local
			i, j: INTEGER
			eac: EAC_BROWSER
			referenced_assemblies: CONSUMED_ASSEMBLY_MAPPING
			cat: CONSUMED_ASSEMBLY_TYPES
			l_dotnet_type_name: STRING
		do
			create eac
			referenced_assemblies := eac.referenced_assemblies (an_assembly)

			from
				i := 1
			until
				referenced_assemblies = Void
				or else
				i > referenced_assemblies.assemblies.count --or Result /= Void
			loop
				cat := eac.consumed_assembly (referenced_assemblies.assemblies.item (i))
				from
					j := 1
				until
					cat = Void
					or else
					j > cat.dotnet_names.count
				loop
					l_dotnet_type_name := cat.dotnet_names.item (j)
					if l_dotnet_type_name /= Void and then l_dotnet_type_name.is_equal (a_dotnet_type_name) then
						Result := cat.eiffel_names.item (j)
					end
						-- Put in cache all types found
					if not types.has (l_dotnet_type_name) and then l_dotnet_type_name /= Void and then cat.eiffel_names.item (j) /= Void then
						types.extend (cat.eiffel_names.item (j), l_dotnet_type_name)
					end
					j := j + 1
				end
				i := i + 1
			end

			if Result = Void then
				Result := a_dotnet_type_name
			end
		ensure
			non_void_result: Result /= Void
		end


note
	copyright:	"Copyright (c) 1984-2006, Eiffel Software"
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


end -- class FINDER
