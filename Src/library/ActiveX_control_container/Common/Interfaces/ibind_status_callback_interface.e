indexing
	description: "Control interfaces. Help file: "
	Note: "Automatically generated by the EiffelCOM Wizard."

deferred class
	IBIND_STATUS_CALLBACK_INTERFACE

inherit
	ECOM_INTERFACE

feature -- Status Report

	on_start_binding_user_precondition (dw_reserved: INTEGER; pib: IBINDING_INTERFACE): BOOLEAN is
			-- User-defined preconditions for `on_start_binding'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	get_priority_user_precondition (pn_priority: INTEGER_REF): BOOLEAN is
			-- User-defined preconditions for `get_priority'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	on_low_resource_user_precondition (reserved: INTEGER): BOOLEAN is
			-- User-defined preconditions for `on_low_resource'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	on_progress_user_precondition (ul_progress: INTEGER; ul_progress_max: INTEGER; ul_status_code: INTEGER; sz_status_text: STRING): BOOLEAN is
			-- User-defined preconditions for `on_progress'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	on_stop_binding_user_precondition (hresult: ECOM_HRESULT; sz_error: STRING): BOOLEAN is
			-- User-defined preconditions for `on_stop_binding'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	get_bind_info_user_precondition (grf_bindf: INTEGER_REF; pbindinfo: X_TAG_REM_BINDINFO_RECORD): BOOLEAN is
			-- User-defined preconditions for `get_bind_info'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	on_data_available_user_precondition (grf_bscf: INTEGER; dw_size: INTEGER; p_formatetc: TAG_REM_FORMATETC_RECORD; p_stgmed: TAG_REM_STGMEDIUM_RECORD): BOOLEAN is
			-- User-defined preconditions for `on_data_available'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	on_object_available_user_precondition (riid: ECOM_GUID; punk: ECOM_INTERFACE): BOOLEAN is
			-- User-defined preconditions for `on_object_available'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

feature -- Basic Operations

	on_start_binding (dw_reserved: INTEGER; pib: IBINDING_INTERFACE) is
			-- No description available.
			-- `dw_reserved' [in].  
			-- `pib' [in].  
		require
			on_start_binding_user_precondition: on_start_binding_user_precondition (dw_reserved, pib)
		deferred

		end

	get_priority (pn_priority: INTEGER_REF) is
			-- No description available.
			-- `pn_priority' [out].  
		require
			non_void_pn_priority: pn_priority /= Void
			get_priority_user_precondition: get_priority_user_precondition (pn_priority)
		deferred

		end

	on_low_resource (reserved: INTEGER) is
			-- No description available.
			-- `reserved' [in].  
		require
			on_low_resource_user_precondition: on_low_resource_user_precondition (reserved)
		deferred

		end

	on_progress (ul_progress: INTEGER; ul_progress_max: INTEGER; ul_status_code: INTEGER; sz_status_text: STRING) is
			-- No description available.
			-- `ul_progress' [in].  
			-- `ul_progress_max' [in].  
			-- `ul_status_code' [in].  
			-- `sz_status_text' [in].  
		require
			on_progress_user_precondition: on_progress_user_precondition (ul_progress, ul_progress_max, ul_status_code, sz_status_text)
		deferred

		end

	on_stop_binding (hresult: ECOM_HRESULT; sz_error: STRING) is
			-- No description available.
			-- `hresult' [in].  
			-- `sz_error' [in].  
		require
			non_void_hresult: hresult /= Void
			on_stop_binding_user_precondition: on_stop_binding_user_precondition (hresult, sz_error)
		deferred

		end

	get_bind_info (grf_bindf: INTEGER_REF; pbindinfo: X_TAG_REM_BINDINFO_RECORD) is
			-- No description available.
			-- `grf_bindf' [out].  
			-- `pbindinfo' [in, out].  
		require
			non_void_grf_bindf: grf_bindf /= Void
			non_void_pbindinfo: pbindinfo /= Void
			valid_pbindinfo: pbindinfo.item /= default_pointer
			get_bind_info_user_precondition: get_bind_info_user_precondition (grf_bindf, pbindinfo)
		deferred

		end

	on_data_available (grf_bscf: INTEGER; dw_size: INTEGER; p_formatetc: TAG_REM_FORMATETC_RECORD; p_stgmed: TAG_REM_STGMEDIUM_RECORD) is
			-- No description available.
			-- `grf_bscf' [in].  
			-- `dw_size' [in].  
			-- `p_formatetc' [in].  
			-- `p_stgmed' [in].  
		require
			non_void_p_formatetc: p_formatetc /= Void
			valid_p_formatetc: p_formatetc.item /= default_pointer
			non_void_p_stgmed: p_stgmed /= Void
			valid_p_stgmed: p_stgmed.item /= default_pointer
			on_data_available_user_precondition: on_data_available_user_precondition (grf_bscf, dw_size, p_formatetc, p_stgmed)
		deferred

		end

	on_object_available (riid: ECOM_GUID; punk: ECOM_INTERFACE) is
			-- No description available.
			-- `riid' [in].  
			-- `punk' [in].  
		require
			non_void_riid: riid /= Void
			valid_riid: riid.item /= default_pointer
			on_object_available_user_precondition: on_object_available_user_precondition (riid, punk)
		deferred

		end

end -- IBIND_STATUS_CALLBACK_INTERFACE

