indexing
	description: " Help file: "
	Note: "Automatically generated by the EiffelCOM Wizard."

deferred class
	X_EXPORT_CLAUSE_INTERFACE

inherit
	ECOM_INTERFACE

feature -- Status Report

	to_string_user_precondition: BOOLEAN is
			-- User-defined preconditions for `to_string'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	get_hash_code_user_precondition: BOOLEAN is
			-- User-defined preconditions for `get_hash_code'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	get_type_user_precondition: BOOLEAN is
			-- User-defined preconditions for `get_type'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	source_name_user_precondition: BOOLEAN is
			-- User-defined preconditions for `source_name'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	string_representation_user_precondition: BOOLEAN is
			-- User-defined preconditions for `string_representation'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	eiffel_keyword_user_precondition: BOOLEAN is
			-- User-defined preconditions for `eiffel_keyword'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	set_source_name_user_precondition (a_source_name: STRING): BOOLEAN is
			-- User-defined preconditions for `set_source_name'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	x_internal_source_name_user_precondition: BOOLEAN is
			-- User-defined preconditions for `x_internal_source_name'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	set__internal_source_name_user_precondition (p_ret_val: STRING): BOOLEAN is
			-- User-defined preconditions for `set__internal_source_name'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	all_keyword_user_precondition: BOOLEAN is
			-- User-defined preconditions for `all_keyword'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	empty_string_user_precondition: BOOLEAN is
			-- User-defined preconditions for `empty_string'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	add_exportation_user_precondition (a_class_name: STRING): BOOLEAN is
			-- User-defined preconditions for `add_exportation'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	exportation_list_user_precondition: BOOLEAN is
			-- User-defined preconditions for `exportation_list'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	closing_curl_bracket_user_precondition: BOOLEAN is
			-- User-defined preconditions for `closing_curl_bracket'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	all_features_exported_user_precondition: BOOLEAN is
			-- User-defined preconditions for `all_features_exported'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	intern_string_representation_user_precondition: BOOLEAN is
			-- User-defined preconditions for `intern_string_representation'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	feature_names_user_precondition: BOOLEAN is
			-- User-defined preconditions for `feature_names'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	comma_user_precondition: BOOLEAN is
			-- User-defined preconditions for `comma'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	set_all_user_precondition: BOOLEAN is
			-- User-defined preconditions for `set_all'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	space_user_precondition: BOOLEAN is
			-- User-defined preconditions for `space'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	opening_curl_bracket_user_precondition: BOOLEAN is
			-- User-defined preconditions for `opening_curl_bracket'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	export_keyword_user_precondition: BOOLEAN is
			-- User-defined preconditions for `export_keyword'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	equals_user_precondition (obj: X_EXPORT_CLAUSE_INTERFACE): BOOLEAN is
			-- User-defined preconditions for `equals'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	add_feature_name_user_precondition (a_feature_name: STRING): BOOLEAN is
			-- User-defined preconditions for `add_feature_name'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	set_exportation_list_user_precondition (a_list: ECOM_INTERFACE): BOOLEAN is
			-- User-defined preconditions for `set_exportation_list'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	make1_user_precondition: BOOLEAN is
			-- User-defined preconditions for `make1'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	set_feature_names_user_precondition (a_list: ECOM_INTERFACE): BOOLEAN is
			-- User-defined preconditions for `set_feature_names'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	x_internal_exportation_list_user_precondition: BOOLEAN is
			-- User-defined preconditions for `x_internal_exportation_list'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	set_ref__internal_exportation_list_user_precondition (p_ret_val: ECOM_INTERFACE): BOOLEAN is
			-- User-defined preconditions for `set_ref__internal_exportation_list'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	x_internal_all_features_exported_user_precondition: BOOLEAN is
			-- User-defined preconditions for `x_internal_all_features_exported'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	set__internal_all_features_exported_user_precondition (p_ret_val: BOOLEAN): BOOLEAN is
			-- User-defined preconditions for `set__internal_all_features_exported'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	x_internal_feature_names_user_precondition: BOOLEAN is
			-- User-defined preconditions for `x_internal_feature_names'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	set_ref__internal_feature_names_user_precondition (p_ret_val: ECOM_INTERFACE): BOOLEAN is
			-- User-defined preconditions for `set_ref__internal_feature_names'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

feature -- Basic Operations

	to_string: STRING is
			-- No description available.
		require
			to_string_user_precondition: to_string_user_precondition
		deferred

		end

	get_hash_code: INTEGER is
			-- No description available.
		require
			get_hash_code_user_precondition: get_hash_code_user_precondition
		deferred

		end

	get_type: INTEGER is
			-- No description available.
		require
			get_type_user_precondition: get_type_user_precondition
		deferred

		end

	source_name: STRING is
			-- No description available.
		require
			source_name_user_precondition: source_name_user_precondition
		deferred

		end

	string_representation: STRING is
			-- No description available.
		require
			string_representation_user_precondition: string_representation_user_precondition
		deferred

		end

	eiffel_keyword: STRING is
			-- No description available.
		require
			eiffel_keyword_user_precondition: eiffel_keyword_user_precondition
		deferred

		end

	set_source_name (a_source_name: STRING) is
			-- No description available.
			-- `a_source_name' [in].  
		require
			set_source_name_user_precondition: set_source_name_user_precondition (a_source_name)
		deferred

		end

	x_internal_source_name: STRING is
			-- No description available.
		require
			x_internal_source_name_user_precondition: x_internal_source_name_user_precondition
		deferred

		end

	set__internal_source_name (p_ret_val: STRING) is
			-- No description available.
			-- `p_ret_val' [in].  
		require
			set__internal_source_name_user_precondition: set__internal_source_name_user_precondition (p_ret_val)
		deferred

		end

	all_keyword: STRING is
			-- No description available.
		require
			all_keyword_user_precondition: all_keyword_user_precondition
		deferred

		end

	empty_string: STRING is
			-- No description available.
		require
			empty_string_user_precondition: empty_string_user_precondition
		deferred

		end

	add_exportation (a_class_name: STRING) is
			-- No description available.
			-- `a_class_name' [in].  
		require
			add_exportation_user_precondition: add_exportation_user_precondition (a_class_name)
		deferred

		end

	exportation_list: ECOM_INTERFACE is
			-- No description available.
		require
			exportation_list_user_precondition: exportation_list_user_precondition
		deferred

		end

	closing_curl_bracket: STRING is
			-- No description available.
		require
			closing_curl_bracket_user_precondition: closing_curl_bracket_user_precondition
		deferred

		end

	all_features_exported: BOOLEAN is
			-- No description available.
		require
			all_features_exported_user_precondition: all_features_exported_user_precondition
		deferred

		end

	intern_string_representation: STRING is
			-- No description available.
		require
			intern_string_representation_user_precondition: intern_string_representation_user_precondition
		deferred

		end

	feature_names: ECOM_INTERFACE is
			-- No description available.
		require
			feature_names_user_precondition: feature_names_user_precondition
		deferred

		end

	comma: STRING is
			-- No description available.
		require
			comma_user_precondition: comma_user_precondition
		deferred

		end

	set_all is
			-- No description available.
		require
			set_all_user_precondition: set_all_user_precondition
		deferred

		end

	space: STRING is
			-- No description available.
		require
			space_user_precondition: space_user_precondition
		deferred

		end

	opening_curl_bracket: STRING is
			-- No description available.
		require
			opening_curl_bracket_user_precondition: opening_curl_bracket_user_precondition
		deferred

		end

	export_keyword: STRING is
			-- No description available.
		require
			export_keyword_user_precondition: export_keyword_user_precondition
		deferred

		end

	equals (obj: X_EXPORT_CLAUSE_INTERFACE): BOOLEAN is
			-- No description available.
			-- `obj' [in].  
		require
			equals_user_precondition: equals_user_precondition (obj)
		deferred

		end

	add_feature_name (a_feature_name: STRING) is
			-- No description available.
			-- `a_feature_name' [in].  
		require
			add_feature_name_user_precondition: add_feature_name_user_precondition (a_feature_name)
		deferred

		end

	set_exportation_list (a_list: ECOM_INTERFACE) is
			-- No description available.
			-- `a_list' [in].  
		require
			set_exportation_list_user_precondition: set_exportation_list_user_precondition (a_list)
		deferred

		end

	make1 is
			-- No description available.
		require
			make1_user_precondition: make1_user_precondition
		deferred

		end

	set_feature_names (a_list: ECOM_INTERFACE) is
			-- No description available.
			-- `a_list' [in].  
		require
			set_feature_names_user_precondition: set_feature_names_user_precondition (a_list)
		deferred

		end

	x_internal_exportation_list: ECOM_INTERFACE is
			-- No description available.
		require
			x_internal_exportation_list_user_precondition: x_internal_exportation_list_user_precondition
		deferred

		end

	set_ref__internal_exportation_list (p_ret_val: ECOM_INTERFACE) is
			-- No description available.
			-- `p_ret_val' [in].  
		require
			set_ref__internal_exportation_list_user_precondition: set_ref__internal_exportation_list_user_precondition (p_ret_val)
		deferred

		end

	x_internal_all_features_exported: BOOLEAN is
			-- No description available.
		require
			x_internal_all_features_exported_user_precondition: x_internal_all_features_exported_user_precondition
		deferred

		end

	set__internal_all_features_exported (p_ret_val: BOOLEAN) is
			-- No description available.
			-- `p_ret_val' [in].  
		require
			set__internal_all_features_exported_user_precondition: set__internal_all_features_exported_user_precondition (p_ret_val)
		deferred

		end

	x_internal_feature_names: ECOM_INTERFACE is
			-- No description available.
		require
			x_internal_feature_names_user_precondition: x_internal_feature_names_user_precondition
		deferred

		end

	set_ref__internal_feature_names (p_ret_val: ECOM_INTERFACE) is
			-- No description available.
			-- `p_ret_val' [in].  
		require
			set_ref__internal_feature_names_user_precondition: set_ref__internal_feature_names_user_precondition (p_ret_val)
		deferred

		end

end -- X_EXPORT_CLAUSE_INTERFACE

