indexing
	description: "Control interfaces. Help file: "
	Note: "Automatically generated by the EiffelCOM Wizard."

class
	X_TAG_OLECMDTEXT_RECORD

inherit
	ECOM_STRUCTURE
		redefine
			make
		end

create
	make,
	make_from_pointer

feature {NONE}  -- Initialization

	make is
			-- Make.
		do
			Precursor {ECOM_STRUCTURE}
		end

	make_from_pointer (a_pointer: POINTER) is
			-- Make from pointer.
		do
			make_by_pointer (a_pointer)
		end

feature -- Access

	cmdtextf: INTEGER is
			-- No description available.
		do
			Result := ccom_x_tag_olecmdtext_cmdtextf (item)
		end

	cw_actual: INTEGER is
			-- No description available.
		do
			Result := ccom_x_tag_olecmdtext_cw_actual (item)
		end

	cw_buf: INTEGER is
			-- No description available.
		do
			Result := ccom_x_tag_olecmdtext_cw_buf (item)
		end

	rgwz: INTEGER_REF is
			-- No description available.
		do
			Result := ccom_x_tag_olecmdtext_rgwz (item)
		end

feature -- Measurement

	structure_size: INTEGER is
			-- Size of structure
		do
			Result := c_size_of_x_tag_olecmdtext
		end

feature -- Basic Operations

	set_cmdtextf (a_cmdtextf: INTEGER) is
			-- Set `cmdtextf' with `a_cmdtextf'.
		do
			ccom_x_tag_olecmdtext_set_cmdtextf (item, a_cmdtextf)
		end

	set_cw_actual (a_cw_actual: INTEGER) is
			-- Set `cw_actual' with `a_cw_actual'.
		do
			ccom_x_tag_olecmdtext_set_cw_actual (item, a_cw_actual)
		end

	set_cw_buf (a_cw_buf: INTEGER) is
			-- Set `cw_buf' with `a_cw_buf'.
		do
			ccom_x_tag_olecmdtext_set_cw_buf (item, a_cw_buf)
		end

	set_rgwz (a_rgwz: INTEGER_REF) is
			-- Set `rgwz' with `a_rgwz'.
		require
			non_void_a_rgwz: a_rgwz /= Void
		do
			ccom_x_tag_olecmdtext_set_rgwz (item, a_rgwz)
		end

feature {NONE}  -- Externals

	c_size_of_x_tag_olecmdtext: INTEGER is
			-- Size of structure
		external
			"C [macro %"ecom_control_library__tagOLECMDTEXT_s.h%"]"
		alias
			"sizeof(ecom_control_library::_tagOLECMDTEXT)"
		end

	ccom_x_tag_olecmdtext_cmdtextf (a_pointer: POINTER): INTEGER is
			-- No description available.
		external
			"C++ [macro %"ecom_control_library__tagOLECMDTEXT_s_impl.h%"](ecom_control_library::_tagOLECMDTEXT *):EIF_INTEGER"
		end

	ccom_x_tag_olecmdtext_set_cmdtextf (a_pointer: POINTER; arg2: INTEGER) is
			-- No description available.
		external
			"C++ [macro %"ecom_control_library__tagOLECMDTEXT_s_impl.h%"](ecom_control_library::_tagOLECMDTEXT *, ULONG)"
		end

	ccom_x_tag_olecmdtext_cw_actual (a_pointer: POINTER): INTEGER is
			-- No description available.
		external
			"C++ [macro %"ecom_control_library__tagOLECMDTEXT_s_impl.h%"](ecom_control_library::_tagOLECMDTEXT *):EIF_INTEGER"
		end

	ccom_x_tag_olecmdtext_set_cw_actual (a_pointer: POINTER; arg2: INTEGER) is
			-- No description available.
		external
			"C++ [macro %"ecom_control_library__tagOLECMDTEXT_s_impl.h%"](ecom_control_library::_tagOLECMDTEXT *, ULONG)"
		end

	ccom_x_tag_olecmdtext_cw_buf (a_pointer: POINTER): INTEGER is
			-- No description available.
		external
			"C++ [macro %"ecom_control_library__tagOLECMDTEXT_s_impl.h%"](ecom_control_library::_tagOLECMDTEXT *):EIF_INTEGER"
		end

	ccom_x_tag_olecmdtext_set_cw_buf (a_pointer: POINTER; arg2: INTEGER) is
			-- No description available.
		external
			"C++ [macro %"ecom_control_library__tagOLECMDTEXT_s_impl.h%"](ecom_control_library::_tagOLECMDTEXT *, ULONG)"
		end

	ccom_x_tag_olecmdtext_rgwz (a_pointer: POINTER): INTEGER_REF is
			-- No description available.
		external
			"C++ [macro %"ecom_control_library__tagOLECMDTEXT_s_impl.h%"](ecom_control_library::_tagOLECMDTEXT *):EIF_REFERENCE"
		end

	ccom_x_tag_olecmdtext_set_rgwz (a_pointer: POINTER; arg2: INTEGER_REF) is
			-- No description available.
		external
			"C++ [macro %"ecom_control_library__tagOLECMDTEXT_s_impl.h%"](ecom_control_library::_tagOLECMDTEXT *, EIF_OBJECT)"
		end

end -- X_TAG_OLECMDTEXT_RECORD

