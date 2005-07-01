indexing
	description: "Dotnet debug value associated with Reference value"
	author: "$Author$"
	date: "$Date$"
	revision: "$Revision$"

class
	EIFNET_DEBUG_REFERENCE_VALUE

inherit
	ABSTRACT_REFERENCE_VALUE
		redefine
			kind
		end
		
	EIFNET_ABSTRACT_DEBUG_VALUE		
		undefine
			address
		redefine
			kind
		end
	
	COMPILER_EXPORTER
		export
			{NONE} all
		undefine
			is_equal
		end

create {RECV_VALUE, ATTR_REQUEST,CALL_STACK_ELEMENT, DEBUG_VALUE_EXPORTER}
	make
--, make_attribute
	
feature {NONE} -- Initialization

	make (a_referenced_value: like icd_referenced_value; a_prepared_value: like icd_value) is
			-- 	Set `value' to `v'.
		require
			a_referenced_value_not_void: a_referenced_value /= Void
			a_prepared_value_not_void: a_prepared_value /= Void
		do
			set_default_name
			
			init_dotnet_data (a_referenced_value, a_prepared_value)

			get_object_value
			if object_value /= Void then
				value_class_token := icd_value_info.value_class_token
				release_object_value
			end

			is_null := icd_value_info.is_null
			if not is_null then
				address := icd_value_info.address_as_hex_string
				if dynamic_class_type = Void then
					is_external_type := True
				end
			end
			register_dotnet_data
		ensure
			value_set: icd_value = a_prepared_value
		end

--	make_attribute (attr_name: like name; a_class: like e_class; v: like value) is
--			-- Set `attr_name' to `name' and `value' to `v'.
--		require
--			not_attr_name_void: attr_name /= Void
--			v_not_void: v /= Void
--		do
--			name := attr_name
--			if a_class /= Void then
--				e_class := a_class
--				is_attribute := True
--			end
--			value := v
--		ensure
--			value_set: value = v
--		end		

feature -- Get 

	has_object_value: BOOLEAN is
		do
			Result := object_value /= Void
		end

	get_object_value is
			-- Get `object_value' value
		require
			object_value_void: not has_object_value
		do
			object_value := icd_value_info.interface_debug_object_value
		end
		
	release_object_value is
			-- Release `object_value'
		require
			has_object_value: has_object_value
		do
			object_value.clean_on_dispose
			object_value := Void
		end
		
feature -- Access

	object_value: ICOR_DEBUG_OBJECT_VALUE
			-- Interface to ICorDebugObjectValue

	value_class_token: INTEGER
			-- class token related to `object_value'

	value_module_file_name: STRING
			-- ICorDebugModule filename related to `object_value'

	dynamic_class: CLASS_C is
			-- Find corresponding CLASS_C to type represented by `value'.
		local
			l_class_type: CLASS_TYPE
		do
			Result := internal_dynamic_class
			if Result = Void then
				l_class_type := dynamic_class_type
				if l_class_type /= Void then
					Result := internal_dynamic_class_type.associated_class
					internal_dynamic_class := Result
				end
			end
		end

	dynamic_class_type: CLASS_TYPE is
			-- Corresponding CLASS_TYPE represented by `value'.
		do
			Result := internal_dynamic_class_type
			if Result = Void then
				if not is_null then
					if icd_value_info.has_object_interface and then value_class_token > 0 then
						Result := icd_value_info.value_class_type						
						if Result = Void then
								--| This means we are dealing with an external type (dotnet)
							internal_dynamic_class := icd_value_info.value_class_c
							Result := internal_dynamic_class.types.first
							is_external_type := True
						end
					else
						internal_dynamic_class := Eiffel_system.System.system_object_class.compiled_class
						Result := internal_dynamic_class.types.first						
					end
					internal_dynamic_class_type := Result
				end
			end
		end

	dump_value: DUMP_VALUE is
			-- Dump_value corresponding to `Current'.
		do
			create Result.make_object_for_dotnet (Current)
		end

feature {NONE} -- Output

	type_and_value: STRING is
			-- Return a string representing `Current'.
		local
			ec: CLASS_C;
		do
			if is_null then
				Result := NONE_representation
			else
				ec := dynamic_class;
				if ec /= Void then
					create Result.make (60)
					Result.append (ec.name_in_upper)
					Result.append (Left_address_delim)
					Result.append (address)
					Result.append (Right_address_delim)
					if is_external_type then
						Result.append (" token=0x"+ value_class_token.to_hex_string)
					end
				else
					create Result.make (20)
					Result.append (Any_class.name_in_upper)
					Result.append (Is_unknown)
				end
			end
		end
		
feature -- Output
		
	children: DS_LIST [ABSTRACT_DEBUG_VALUE] is
			-- List of all sub-items of `Current'. 
			-- May be void if there are no children.
			-- Generated on demand.
			-- (sorted by name)
		do
			Result := attributes
			if Result = Void then
				if is_external_type then
					Result := children_from_external_type
				else
					Result := children_from_eiffel_type
				end
				attributes := Result				
			end
		end
		
	attributes: DS_LIST [ABSTRACT_DEBUG_VALUE]
		
feature {NONE} -- Children implementation

	children_from_eiffel_type: DS_LIST [ABSTRACT_DEBUG_VALUE] is
			-- List of all sub-items of `Current'. 
			-- May be void if there are no children.
			-- Generated on demand.
			-- (sorted by name)
		local
			l_feature_table: FEATURE_TABLE
			l_feature_i: FEATURE_I

			l_att_debug_value: ABSTRACT_DEBUG_VALUE
			l_icd_class: ICOR_DEBUG_CLASS
		do
			get_object_value
			if object_value /= Void then
				l_icd_class := object_value.get_class
				if l_icd_class /= Void then
					if dynamic_class /= Void then
						l_feature_table := dynamic_class.feature_table
						create {DS_ARRAYED_LIST [ABSTRACT_DEBUG_VALUE]} Result.make (l_feature_table.count)
						from
							l_feature_table.start
						until
							l_feature_table.after
						loop
							l_feature_i := l_feature_table.item_for_iteration
							debug ("DEBUGGER_TRACE_CHILDREN")
								print (">>> CHILDREN :: " + l_feature_i.feature_name + "<<<%N")
								print ("%T - from feature_i     => "
										+ l_feature_i.written_class.name_in_upper + "." + l_feature_i.feature_name
										+ " :: " + l_feature_i.written_class.class_id.out + "%N")
								print ("%T - from dynamic_class => " + dynamic_class.name_in_upper
										+ "." + l_feature_i.feature_name + " :: " + dynamic_class.class_id.out + "%N")
							end
							if l_feature_i.is_attribute then
								l_att_debug_value := attribute_value (object_value, l_icd_class, l_feature_i)
								if l_att_debug_value /= Void then
									Result.put_last (l_att_debug_value)
								end
							end
							l_feature_table.forth
						end
					end
				end
				release_object_value
			end
		end

	attribute_value (a_obj_value: ICOR_DEBUG_OBJECT_VALUE; a_icd_class: ICOR_DEBUG_CLASS; f: FEATURE_I): ABSTRACT_DEBUG_VALUE is
			-- Attribute's value in the context of Current related to `f'
		require
			object_value_not_void: a_obj_value /= Void
		local
			l_att_token: INTEGER
			l_att_icd_debug_value: ICOR_DEBUG_VALUE
		do
			l_att_token := Il_debug_info_recorder.feature_token_for_feat_and_class_type (f, dynamic_class_type) 
			if l_att_token /= 0 then
				l_att_icd_debug_value := a_obj_value.get_field_value (a_icd_class, l_att_token)
				if l_att_icd_debug_value /= Void then
					Result := debug_value_from_icdv (l_att_icd_debug_value)
					if Result /= Void then
						Result.set_name (f.feature_name)
					else
						create {DEBUG_VALUE[INTEGER]} Result.make (Sk_int32, 0)
						Result.set_name ("ERROR on " + f.feature_name)
							--| FIXME JFIAT : 2003/10/24 maybe add DUMMY_VALUE to say 
							--| we had problem to get its value ...
						debug ("DEBUGGER_TRACE_CHILDREN")
							print ("Unable to build debug value for : " 
									+ dynamic_class.name_in_upper + "." + f.feature_name 
									+ "%N"
								)
						end
					end
				end
			end
		end
		
feature -- Status

	kind: INTEGER is
			-- Actual type of `Current'. cf possible codes underneath.
			-- Used to display the corresponding icon.
		do
			if is_null then
				Result := Void_value
			else
				if is_external_type then
					if is_static then
						Result := Static_external_reference_value
					else
						Result := External_reference_value
					end
				else
					if is_static then
						Result := Static_reference_value
					else
						Result := Reference_value
					end					
				end
			end
		end

feature -- Once request

	once_function_value (a_feat: E_FEATURE): ABSTRACT_DEBUG_VALUE is
			-- If Result = Void, this mean the once has not been already called !
		require
			object_value_not_void: object_value /= Void
			is_once: a_feat.is_once
			has_result: a_feat.is_function
		local
			l_icd_class: ICOR_DEBUG_CLASS
			l_origin_class_c: CLASS_C
			l_cl_type_a: CL_TYPE_A
			l_adapted_class_type: CLASS_TYPE

			l_icd_dv_result: ICOR_DEBUG_VALUE
			l_icd_frame: ICOR_DEBUG_FRAME
			l_eifnet_debugger: EIFNET_DEBUGGER
		do
			--| In case the once is attached to an ancestor
			--| we need to access the static of the correct ICOR_DEBUG_CLASS
			l_origin_class_c := a_feat.written_class
			l_eifnet_debugger := Application.imp_dotnet.eifnet_debugger

			if dynamic_class.is_equal (l_origin_class_c) then
					--| The Once is not inherited
				if object_value /= Void then
					l_icd_class := object_value.get_class
					l_adapted_class_type := dynamic_class_type
				end
			else
				if l_origin_class_c.types.count = 1 then
					l_adapted_class_type := l_origin_class_c.types.first
				else
					--| The Once is inherited
	
					--| let's search and find the correct CLASS_TYPE among the parents
					--| this will solve the problem of inherited once and generic class
					--| the level on inheritance is represented by the CLASS_C
					--| then the derivation of the GENERIC by the CLASS_TYPE
					--| among the parent we know the right CLASS_TYPE
					--| so first we localite the CLASS_C then we keep the CLASS_TYPE					
					l_cl_type_a := dynamic_class_type.type.type_a
					l_adapted_class_type := l_cl_type_a.find_class_type (l_origin_class_c).type_i.associated_class_type
				end

				check
					found_item_is_correct: l_adapted_class_type /= Void 
							and then l_adapted_class_type.associated_class = l_origin_class_c
				end

				l_icd_class := l_eifnet_debugger.icor_debug_class (l_adapted_class_type)
			end

			if l_icd_class /= Void then
					--| now we have the correct ICOR_DEBUG_CLASS as a_icd_class
					--| and we know the good CLASS_TYPE as
				l_icd_frame := eifnet_debugger.current_stack_icor_debug_frame
				l_icd_dv_result := l_eifnet_debugger.once_function_value_on_icd_class (l_icd_frame, l_icd_class, l_adapted_class_type, a_feat)
				if l_eifnet_debugger.last_once_available then
					if l_eifnet_debugger.last_once_failed then
						Result := error_value (a_feat.name , "exception occurred")
					else
						if l_icd_dv_result /= Void then
							Result := debug_value_from_icdv (l_icd_dv_result)
							Result.set_name (a_feat.name)
						end
					end
				else
					Result := error_value (a_feat.name , "Could not retrieve information")
				end
			end

			debug ("DEBUGGER_TRACE")
				print ("- " + a_feat.written_class.name_in_upper + " ")
				print (">>" + a_feat.name + " Result /= Void =? " + (Result /= Void).out + "%N") 
			end
		end
	
feature {NONE} -- Implementation

	internal_dynamic_class: like dynamic_class

	internal_dynamic_class_type: like dynamic_class_type

end -- class EIFNET_DEBUG_REFERENCE_VALUE
