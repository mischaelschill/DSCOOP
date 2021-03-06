﻿note
	description: "Access to a C external."
	legal: "See notice at end of class."
	status: "See notice at end of class."

class EXTERNAL_B

inherit
	CALL_ACCESS_B
		rename
			precursor_type as static_class_type,
			set_precursor_type as set_static_class_type
		redefine
			same, is_external, set_parameters, parameters, enlarged, enlarged_on,
			is_feature_special, is_unsafe, optimized_byte_node,
			calls_special_features, size, context_type,
			pre_inlined_code, inlined_byte_code,
			need_target, is_constant_expression, has_call, allocates_memory
		end

	SHARED_INCLUDE

	SHARED_IL_CONSTANTS
		export
			{NONE} all
		end

	INTERNAL_COMPILER_STRING_EXPORTER

feature -- Visitor

	process (v: BYTE_NODE_VISITOR)
			-- Process current element.
		local
			c: CL_TYPE_A
			f: FEATURE_I
		do
			c ?= context_type
			if system.il_generation and then not (c.is_expanded and c.is_basic) then
					-- We cannot optimize .NET feature calls at this point. See eweasel test#term202
					-- for an example where trying to optimize is not working properly: the issue is
					-- that the typing gets confused between inherited context and descendant context
					-- we do call `{BYTE_CONTEXT}.real_type
					-- We only optimize external calls on basic expanded type.
				v.process_external_b (Current)
			else

				if not is_static_call and then not context.is_written_context then
						-- Ensure the feature is not redeclared into attribute or internal routine.
						-- and if redeclared as an external, make sure it is not redeclared differently.
					f := c.base_class.feature_of_rout_id (routine_id)
					if equal (f.extension, extension) then
						f := Void
					end
				end
				if f = Void then
						-- Process feature as an external routine.
					v.process_external_b (Current)
				else
						-- Create new byte node and process it instead of the current one.
					byte_node (f, c).process (v)
				end
			end
		end

feature

	parameters: BYTE_LIST [PARAMETER_B];
			-- Feature parameters: can be Void

feature -- Attributes for externals

	extension: EXTERNAL_EXT_I
			-- Encapsulation of external extensions

	external_name_id: INTEGER
			-- Name ID of C external.

	encapsulated: BOOLEAN;
			-- Has the feature some assertion declared ?

	is_external: BOOLEAN = True;
			-- Access is an external call

	is_static_call: BOOLEAN
			-- Is current external call made through a static access?

	precursor_type: like static_class_type
		require
			il_generation: System.il_generation
			not_a_static_call: not is_static_call
		do
			Result := static_class_type
		end

feature {INTERNAL_COMPILER_STRING_EXPORTER} -- Attributes for externals

	external_name: STRING
			-- Name of C external.
		require
			external_name_id_set: external_name_id > 0
		do
			Result := Names_heap.item (external_name_id)
		ensure
			result_not_void: Result /= Void
			result_not_empty: not Result.is_empty
		end

feature -- Status report

	is_constant_expression: BOOLEAN
			-- Is constant expression?
		do
				-- For now only a .NET enum type is constant for an external call.
			Result := attached {IL_ENUM_EXTENSION_I} extension
		end

	has_call: BOOLEAN = True
			-- <Precursor>

	allocates_memory: BOOLEAN = True
			-- <Precursor>
			-- An external is a black box that may allocate Eiffel memory when called.

feature -- Context type

	context_type: TYPE_A
			-- Context type of the access (properly instantiated)
		do
			if static_class_type = Void then
				Result := Precursor {CALL_ACCESS_B}
			else
				Result := Context.real_type (static_class_type)
				if Result.is_multi_constrained then
					check
						has_multi_constraint_static: has_multi_constraint_static
					end
					Result := context.real_type (multi_constraint_static)
				end
			end
		end

feature -- Routines for externals

	set_extension (e: like extension)
			-- Assign `e' to `extension'.
		do
			extension := e
		end;

	set_parameters (p: like parameters)
			-- Assign `p' to `parameters'.
		local
			i: INTEGER
		do
			parameters := p
			if p /= Void then
					-- Set all parameter parents to `Current'.
				from
					i := p.count
				until
					i = 0
				loop
					p [i].set_parent (Current)
					i := i - 1
				end
			end
		end

	enable_static_call
			-- Set `is_static_call' to `True'.
		do
			is_static_call := True
			set_call_kind (call_kind_unqualified)
		ensure
			is_static_call_set: is_static_call
		end

	init (f: FEATURE_I)
			-- Initialization
		require
			good_argument: f /= Void
			is_valid_feature_for_normal_generation: not System.il_generation implies f.is_external
			is_valid_feature_for_il_generation: System.il_generation implies
				(f.is_external or f.is_attribute or f.is_deferred or f.is_constant)
		do
			feature_name_id := f.feature_name_id
			routine_id := f.rout_id_set.first
			if System.il_generation and f.is_c_external then
				feature_id := f.origin_feature_id
				written_in := f.origin_class_id
			else
				feature_id := f.feature_id
				written_in := f.written_in
			end
		end;

	set_external_name_id (id: INTEGER)
			-- Assign `id' to `external_name_id'.
		require
			valid_id: id > 0
		do
			external_name_id := id
		ensure
			external_name_id_set: external_name_id = id
		end

	set_encapsulated (b: BOOLEAN)
			-- Assign `b' to `encapsulated'
		do
			encapsulated := b;
		end;

feature {STATIC_ACCESS_AS} -- Settings

	set_written_in (id: INTEGER)
			-- Set `written_in' to `id'.
		require
			valid_id: id > 0
		do
			written_in := id
		ensure
			written_in_set: written_in = id
		end

feature -- Status report

	is_feature_special (compilation_type: BOOLEAN; target_type: BASIC_A): BOOLEAN
			-- Search for feature_name in `special_routines'.
			-- This is used for simple types only.
			-- If found return True (and keep reference position).
			-- Otherwize, return false
		do
			Result := special_routines.has (feature_name_id, compilation_type, target_type)
		end

	same (other: ACCESS_B): BOOLEAN
			-- Is `other' the same access as Current ?
		do
			if attached {EXTERNAL_B} other as external_b then
				Result := external_name_id = external_b.external_name_id
			end
		end

	enlarged: CALL_ACCESS_B
			-- Enlarge the tree to get more attributes and return the
			-- new enlarged tree node.
		do
				-- Fallback to default implementation.
			Result := enlarged_on (context_type)
		end

	enlarged_on (a_type_i: TYPE_A): CALL_ACCESS_B
			-- Enlarged byte node evaluated in the context of `a_type_i'.
		local
			external_bl: EXTERNAL_BL
			f: FEATURE_I
		do
			if not is_static_call and then not context.is_written_context then
					-- Ensure the feature is not redeclared into attribute or internal routine.
					-- and if redeclared as an external, make sure it is not redeclared differently.
				if attached {CL_TYPE_A} a_type_i as c then
					f := c.base_class.feature_of_rout_id (routine_id)
					if equal (f.extension, extension) then
						f := Void
					end
				end
			end
			if f = Void then
				if context.final_mode then
					create external_bl
				else
					create {EXTERNAL_BW} external_bl.make
				end
				external_bl.fill_from (Current)
				Result := external_bl
			else
				Result ?= byte_node (f, a_type_i).enlarged
			end
		end

feature -- IL code generation

	need_target: BOOLEAN
			-- Does current call need a target to be performed?
			-- Meaning that it is not a static call.
		do
			if System.il_generation then
					-- In IL code generation, it only applies to .NET externals or Eiffel builtins
					-- as C externals still needs an object (at least for the time being).
				if (extension.is_il or extension.is_built_in) then
						-- A call is static if we actually do a static calls ({A}.call) or if the
						-- routine being called does not need a target object.
					Result := not is_static_call and not extension.is_static
				else
					Result := True
				end
			else
				Result := False
			end
		end

feature -- Array optimization

	is_unsafe: BOOLEAN
		do
				-- An external call can have access to the entire system
				-- and move. resize objects. Thus it is unsafe to call
				-- an external feature.
			Result := True
		end

	optimized_byte_node: like Current
		do
			Result := Current
			if parameters /= Void then
				parameters := parameters.optimized_byte_node
			end
		end

	calls_special_features (array_desc: INTEGER): BOOLEAN
		do
			if parameters /= Void then
				Result := parameters.calls_special_features (array_desc)
			end
		end

feature -- Inlining

	size: INTEGER
		do
			if parameters /= Void then
				Result := 1 + parameters.size
			else
				Result := 1
			end
		end

	pre_inlined_code: CALL_B
		local
			inlined_current_b: INLINED_CURRENT_B
		do
			if parent /= Void then
				Result := Current
			else
				create parent
				create inlined_current_b
				parent.set_target (inlined_current_b)
				inlined_current_b.set_parent (parent)
				parent.set_message (Current)
				Result := parent
			end
			if parameters /= Void then
				parameters := parameters.pre_inlined_code
			end
		end

	inlined_byte_code: like Current
		do
			Result := Current
			type := real_type (type)
			if static_class_type /= Void then
				static_class_type ?= real_type (static_class_type)
			end
			if parameters /= Void then
				parameters := parameters.inlined_byte_code
			end
			if has_multi_constraint_static then
				multi_constraint_static := real_type (multi_constraint_static)
			end
		end

note
	copyright:	"Copyright (c) 1984-2016, Eiffel Software"
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
