note
	description: "Control interfaces. Help file: "
	legal: "See notice at end of class."
	status: "See notice at end of class."
	generator: "Automatically generated by the EiffelCOM Wizard."

class
	X_COAUTHINFO_RECORD

inherit
	ECOM_STRUCTURE
		redefine
			make
		end

create
	make,
	make_from_pointer

feature {NONE}  -- Initialization

	make
			-- Make.
		do
			Precursor {ECOM_STRUCTURE}
		end

	make_from_pointer (a_pointer: POINTER)
			-- Make from pointer.
		do
			make_by_pointer (a_pointer)
		end

feature -- Access

	dw_authn_svc: INTEGER
			-- No description available.
		do
			Result := ccom_x_coauthinfo_dw_authn_svc (item)
		end

	dw_authz_svc: INTEGER
			-- No description available.
		do
			Result := ccom_x_coauthinfo_dw_authz_svc (item)
		end

	pwsz_server_princ_name: STRING
			-- No description available.
		do
			Result := ccom_x_coauthinfo_pwsz_server_princ_name (item)
		end

	dw_authn_level: INTEGER
			-- No description available.
		do
			Result := ccom_x_coauthinfo_dw_authn_level (item)
		end

	dw_impersonation_level: INTEGER
			-- No description available.
		do
			Result := ccom_x_coauthinfo_dw_impersonation_level (item)
		end

	p_auth_identity_data: X_COAUTHIDENTITY_RECORD
			-- No description available.
		do
			Result := ccom_x_coauthinfo_p_auth_identity_data (item)
		end

	dw_capabilities: INTEGER
			-- No description available.
		do
			Result := ccom_x_coauthinfo_dw_capabilities (item)
		end

feature -- Measurement

	structure_size: INTEGER
			-- Size of structure
		do
			Result := c_size_of_x_coauthinfo
		end

feature -- Basic Operations

	set_dw_authn_svc (a_dw_authn_svc: INTEGER)
			-- Set `dw_authn_svc' with `a_dw_authn_svc'.
		do
			ccom_x_coauthinfo_set_dw_authn_svc (item, a_dw_authn_svc)
		end

	set_dw_authz_svc (a_dw_authz_svc: INTEGER)
			-- Set `dw_authz_svc' with `a_dw_authz_svc'.
		do
			ccom_x_coauthinfo_set_dw_authz_svc (item, a_dw_authz_svc)
		end

	set_pwsz_server_princ_name (a_pwsz_server_princ_name: STRING)
			-- Set `pwsz_server_princ_name' with `a_pwsz_server_princ_name'.
		do
			ccom_x_coauthinfo_set_pwsz_server_princ_name (item, a_pwsz_server_princ_name)
		end

	set_dw_authn_level (a_dw_authn_level: INTEGER)
			-- Set `dw_authn_level' with `a_dw_authn_level'.
		do
			ccom_x_coauthinfo_set_dw_authn_level (item, a_dw_authn_level)
		end

	set_dw_impersonation_level (a_dw_impersonation_level: INTEGER)
			-- Set `dw_impersonation_level' with `a_dw_impersonation_level'.
		do
			ccom_x_coauthinfo_set_dw_impersonation_level (item, a_dw_impersonation_level)
		end

	set_p_auth_identity_data (a_p_auth_identity_data: X_COAUTHIDENTITY_RECORD)
			-- Set `p_auth_identity_data' with `a_p_auth_identity_data'.
		require
			non_void_a_p_auth_identity_data: a_p_auth_identity_data /= Void
			valid_a_p_auth_identity_data: a_p_auth_identity_data.item /= default_pointer
		do
			ccom_x_coauthinfo_set_p_auth_identity_data (item, a_p_auth_identity_data.item)
		end

	set_dw_capabilities (a_dw_capabilities: INTEGER)
			-- Set `dw_capabilities' with `a_dw_capabilities'.
		do
			ccom_x_coauthinfo_set_dw_capabilities (item, a_dw_capabilities)
		end

feature {NONE}  -- Externals

	c_size_of_x_coauthinfo: INTEGER
			-- Size of structure
		external
			"C [macro %"ecom_control_library__COAUTHINFO_s.h%"]"
		alias
			"sizeof(ecom_control_library::_COAUTHINFO)"
		end

	ccom_x_coauthinfo_dw_authn_svc (a_pointer: POINTER): INTEGER
			-- No description available.
		external
			"C++ [macro %"ecom_control_library__COAUTHINFO_s_impl.h%"](ecom_control_library::_COAUTHINFO *):EIF_INTEGER"
		end

	ccom_x_coauthinfo_set_dw_authn_svc (a_pointer: POINTER; arg2: INTEGER)
			-- No description available.
		external
			"C++ [macro %"ecom_control_library__COAUTHINFO_s_impl.h%"](ecom_control_library::_COAUTHINFO *, ULONG)"
		end

	ccom_x_coauthinfo_dw_authz_svc (a_pointer: POINTER): INTEGER
			-- No description available.
		external
			"C++ [macro %"ecom_control_library__COAUTHINFO_s_impl.h%"](ecom_control_library::_COAUTHINFO *):EIF_INTEGER"
		end

	ccom_x_coauthinfo_set_dw_authz_svc (a_pointer: POINTER; arg2: INTEGER)
			-- No description available.
		external
			"C++ [macro %"ecom_control_library__COAUTHINFO_s_impl.h%"](ecom_control_library::_COAUTHINFO *, ULONG)"
		end

	ccom_x_coauthinfo_pwsz_server_princ_name (a_pointer: POINTER): STRING
			-- No description available.
		external
			"C++ [macro %"ecom_control_library__COAUTHINFO_s_impl.h%"](ecom_control_library::_COAUTHINFO *):EIF_REFERENCE"
		end

	ccom_x_coauthinfo_set_pwsz_server_princ_name (a_pointer: POINTER; arg2: STRING)
			-- No description available.
		external
			"C++ [macro %"ecom_control_library__COAUTHINFO_s_impl.h%"](ecom_control_library::_COAUTHINFO *, EIF_OBJECT)"
		end

	ccom_x_coauthinfo_dw_authn_level (a_pointer: POINTER): INTEGER
			-- No description available.
		external
			"C++ [macro %"ecom_control_library__COAUTHINFO_s_impl.h%"](ecom_control_library::_COAUTHINFO *):EIF_INTEGER"
		end

	ccom_x_coauthinfo_set_dw_authn_level (a_pointer: POINTER; arg2: INTEGER)
			-- No description available.
		external
			"C++ [macro %"ecom_control_library__COAUTHINFO_s_impl.h%"](ecom_control_library::_COAUTHINFO *, ULONG)"
		end

	ccom_x_coauthinfo_dw_impersonation_level (a_pointer: POINTER): INTEGER
			-- No description available.
		external
			"C++ [macro %"ecom_control_library__COAUTHINFO_s_impl.h%"](ecom_control_library::_COAUTHINFO *):EIF_INTEGER"
		end

	ccom_x_coauthinfo_set_dw_impersonation_level (a_pointer: POINTER; arg2: INTEGER)
			-- No description available.
		external
			"C++ [macro %"ecom_control_library__COAUTHINFO_s_impl.h%"](ecom_control_library::_COAUTHINFO *, ULONG)"
		end

	ccom_x_coauthinfo_p_auth_identity_data (a_pointer: POINTER): X_COAUTHIDENTITY_RECORD
			-- No description available.
		external
			"C++ [macro %"ecom_control_library__COAUTHINFO_s_impl.h%"](ecom_control_library::_COAUTHINFO *):EIF_REFERENCE"
		end

	ccom_x_coauthinfo_set_p_auth_identity_data (a_pointer: POINTER; arg2: POINTER)
			-- No description available.
		external
			"C++ [macro %"ecom_control_library__COAUTHINFO_s_impl.h%"](ecom_control_library::_COAUTHINFO *, ecom_control_library::_COAUTHIDENTITY *)"
		end

	ccom_x_coauthinfo_dw_capabilities (a_pointer: POINTER): INTEGER
			-- No description available.
		external
			"C++ [macro %"ecom_control_library__COAUTHINFO_s_impl.h%"](ecom_control_library::_COAUTHINFO *):EIF_INTEGER"
		end

	ccom_x_coauthinfo_set_dw_capabilities (a_pointer: POINTER; arg2: INTEGER)
			-- No description available.
		external
			"C++ [macro %"ecom_control_library__COAUTHINFO_s_impl.h%"](ecom_control_library::_COAUTHINFO *, ULONG)"
		end

note
	copyright:	"Copyright (c) 1984-2006, Eiffel Software and others"
	license:	"Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			 Eiffel Software
			 356 Storke Road, Goleta, CA 93117 USA
			 Telephone 805-685-1006, Fax 805-685-6869
			 Website http://www.eiffel.com
			 Customer support http://support.eiffel.com
		]"




end -- X_COAUTHINFO_RECORD

