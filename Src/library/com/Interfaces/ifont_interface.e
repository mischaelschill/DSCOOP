note
	description: "Font Object. OLE Automation."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	generator: "Automatically generated by the EiffelCOM Wizard."

deferred class
	IFONT_INTERFACE

inherit
	ECOM_INTERFACE

feature -- Status Report

	name_user_precondition: BOOLEAN
			-- User-defined preconditions for `name'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	set_name_user_precondition (pname: STRING): BOOLEAN
			-- User-defined preconditions for `set_name'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	size_user_precondition: BOOLEAN
			-- User-defined preconditions for `size'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	set_size_user_precondition (psize: ECOM_CURRENCY): BOOLEAN
			-- User-defined preconditions for `set_size'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	bold_user_precondition: BOOLEAN
			-- User-defined preconditions for `bold'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	set_bold_user_precondition (pbold: BOOLEAN): BOOLEAN
			-- User-defined preconditions for `set_bold'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	italic_user_precondition: BOOLEAN
			-- User-defined preconditions for `italic'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	set_italic_user_precondition (pitalic: BOOLEAN): BOOLEAN
			-- User-defined preconditions for `set_italic'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	underline_user_precondition: BOOLEAN
			-- User-defined preconditions for `underline'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	set_underline_user_precondition (punderline: BOOLEAN): BOOLEAN
			-- User-defined preconditions for `set_underline'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	strikethrough_user_precondition: BOOLEAN
			-- User-defined preconditions for `strikethrough'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	set_strikethrough_user_precondition (pstrikethrough: BOOLEAN): BOOLEAN
			-- User-defined preconditions for `set_strikethrough'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	weight_user_precondition: BOOLEAN
			-- User-defined preconditions for `weight'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	set_weight_user_precondition (pweight: INTEGER): BOOLEAN
			-- User-defined preconditions for `set_weight'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	charset_user_precondition: BOOLEAN
			-- User-defined preconditions for `charset'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	set_charset_user_precondition (pcharset: INTEGER): BOOLEAN
			-- User-defined preconditions for `set_charset'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	h_font_user_precondition: BOOLEAN
			-- User-defined preconditions for `h_font'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	clone1_user_precondition (ppfont: CELL [IFONT_INTERFACE]): BOOLEAN
			-- User-defined preconditions for `clone1'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	is_equal1_user_precondition (pfont_other: IFONT_INTERFACE): BOOLEAN
			-- User-defined preconditions for `is_equal1'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	set_ratio_user_precondition (cy_logical: INTEGER; cy_himetric: INTEGER): BOOLEAN
			-- User-defined preconditions for `set_ratio'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	add_ref_hfont_user_precondition (a_h_font: INTEGER): BOOLEAN
			-- User-defined preconditions for `add_ref_hfont'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	release_hfont_user_precondition (a_h_font: INTEGER): BOOLEAN
			-- User-defined preconditions for `release_hfont'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

feature -- Basic Operations

	name: STRING
			-- No description available.
		require
			name_user_precondition: name_user_precondition
		deferred

		ensure
			non_void_name: Result /= Void
		end

	set_name (pname: STRING)
			-- No description available.
			-- `pname' [in].
		require
			set_name_user_precondition: set_name_user_precondition (pname)
		deferred

		end

	size: ECOM_CURRENCY
			-- No description available.
		require
			size_user_precondition: size_user_precondition
		deferred

		ensure
			non_void_size: Result /= Void
			valid_size: Result.item /= default_pointer
		end

	set_size (psize: ECOM_CURRENCY)
			-- No description available.
			-- `psize' [in].
		require
			non_void_psize: psize /= Void
			valid_psize: psize.item /= default_pointer
			set_size_user_precondition: set_size_user_precondition (psize)
		deferred

		end

	bold: BOOLEAN
			-- No description available.
		require
			bold_user_precondition: bold_user_precondition
		deferred

		end

	set_bold (pbold: BOOLEAN)
			-- No description available.
			-- `pbold' [in].
		require
			set_bold_user_precondition: set_bold_user_precondition (pbold)
		deferred

		end

	italic: BOOLEAN
			-- No description available.
		require
			italic_user_precondition: italic_user_precondition
		deferred

		end

	set_italic (pitalic: BOOLEAN)
			-- No description available.
			-- `pitalic' [in].
		require
			set_italic_user_precondition: set_italic_user_precondition (pitalic)
		deferred

		end

	underline: BOOLEAN
			-- No description available.
		require
			underline_user_precondition: underline_user_precondition
		deferred

		end

	set_underline (punderline: BOOLEAN)
			-- No description available.
			-- `punderline' [in].
		require
			set_underline_user_precondition: set_underline_user_precondition (punderline)
		deferred

		end

	strikethrough: BOOLEAN
			-- No description available.
		require
			strikethrough_user_precondition: strikethrough_user_precondition
		deferred

		end

	set_strikethrough (pstrikethrough: BOOLEAN)
			-- No description available.
			-- `pstrikethrough' [in].
		require
			set_strikethrough_user_precondition: set_strikethrough_user_precondition (pstrikethrough)
		deferred

		end

	weight: INTEGER
			-- No description available.
		require
			weight_user_precondition: weight_user_precondition
		deferred

		end

	set_weight (pweight: INTEGER)
			-- No description available.
			-- `pweight' [in].
		require
			set_weight_user_precondition: set_weight_user_precondition (pweight)
		deferred

		end

	charset: INTEGER
			-- No description available.
		require
			charset_user_precondition: charset_user_precondition
		deferred

		end

	set_charset (pcharset: INTEGER)
			-- No description available.
			-- `pcharset' [in].
		require
			set_charset_user_precondition: set_charset_user_precondition (pcharset)
		deferred

		end

	h_font: INTEGER
			-- No description available.
		require
			h_font_user_precondition: h_font_user_precondition
		deferred

		end

	clone1 (ppfont: CELL [IFONT_INTERFACE])
			-- No description available.
			-- `ppfont' [out].
		require
			non_void_ppfont: ppfont /= Void
			clone1_user_precondition: clone1_user_precondition (ppfont)
		deferred

		ensure
			valid_ppfont: ppfont.item /= Void
		end

	is_equal1 (pfont_other: IFONT_INTERFACE)
			-- No description available.
			-- `pfont_other' [in].
		require
			non_void_pfont_other: pfont_other /= Void
			valid_pfont_other: pfont_other.item /= default_pointer
			is_equal1_user_precondition: is_equal1_user_precondition (pfont_other)
		deferred

		end

	set_ratio (cy_logical: INTEGER; cy_himetric: INTEGER)
			-- No description available.
			-- `cy_logical' [in].
			-- `cy_himetric' [in].
		require
			set_ratio_user_precondition: set_ratio_user_precondition (cy_logical, cy_himetric)
		deferred

		end

	add_ref_hfont (a_h_font: INTEGER)
			-- No description available.
			-- `a_h_font' [in].
		require
			add_ref_hfont_user_precondition: add_ref_hfont_user_precondition (a_h_font)
		deferred

		end

	release_hfont (a_h_font: INTEGER)
			-- No description available.
			-- `a_h_font' [in].
		require
			release_hfont_user_precondition: release_hfont_user_precondition (a_h_font)
		deferred

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




end -- IFONT_INTERFACE

