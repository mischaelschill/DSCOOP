note
	description: "Control interfaces. Help file: "
	legal: "See notice at end of class."
	status: "See notice at end of class."
	Note: "Automatically generated by the EiffelCOM Wizard."

deferred class
	IDROP_TARGET_INTERFACE

inherit
	ECOM_INTERFACE

feature -- Status Report

	drag_enter_user_precondition (p_data_obj: IDATA_OBJECT_INTERFACE; grf_key_state: INTEGER; pt: X_POINTL_RECORD; pdw_effect: INTEGER_REF): BOOLEAN
			-- User-defined preconditions for `drag_enter'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	drag_over_user_precondition (grf_key_state: INTEGER; pt: X_POINTL_RECORD; pdw_effect: INTEGER_REF): BOOLEAN
			-- User-defined preconditions for `drag_over'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	drag_leave_user_precondition: BOOLEAN
			-- User-defined preconditions for `drag_leave'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	drop_user_precondition (p_data_obj: IDATA_OBJECT_INTERFACE; grf_key_state: INTEGER; pt: X_POINTL_RECORD; pdw_effect: INTEGER_REF): BOOLEAN
			-- User-defined preconditions for `drop'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

feature -- Basic Operations

	drag_enter (p_data_obj: IDATA_OBJECT_INTERFACE; grf_key_state: INTEGER; pt: X_POINTL_RECORD; pdw_effect: INTEGER_REF)
			-- No description available.
			-- `p_data_obj' [in].  
			-- `grf_key_state' [in].  
			-- `pt' [in].  
			-- `pdw_effect' [in, out].  
		require
			non_void_pt: pt /= Void
			valid_pt: pt.item /= default_pointer
			non_void_pdw_effect: pdw_effect /= Void
			drag_enter_user_precondition: drag_enter_user_precondition (p_data_obj, grf_key_state, pt, pdw_effect)
		deferred

		end

	drag_over (grf_key_state: INTEGER; pt: X_POINTL_RECORD; pdw_effect: INTEGER_REF)
			-- No description available.
			-- `grf_key_state' [in].  
			-- `pt' [in].  
			-- `pdw_effect' [in, out].  
		require
			non_void_pt: pt /= Void
			valid_pt: pt.item /= default_pointer
			non_void_pdw_effect: pdw_effect /= Void
			drag_over_user_precondition: drag_over_user_precondition (grf_key_state, pt, pdw_effect)
		deferred

		end

	drag_leave
			-- No description available.
		require
			drag_leave_user_precondition: drag_leave_user_precondition
		deferred

		end

	drop (p_data_obj: IDATA_OBJECT_INTERFACE; grf_key_state: INTEGER; pt: X_POINTL_RECORD; pdw_effect: INTEGER_REF)
			-- No description available.
			-- `p_data_obj' [in].  
			-- `grf_key_state' [in].  
			-- `pt' [in].  
			-- `pdw_effect' [in, out].  
		require
			non_void_pt: pt /= Void
			valid_pt: pt.item /= default_pointer
			non_void_pdw_effect: pdw_effect /= Void
			drop_user_precondition: drop_user_precondition (p_data_obj, grf_key_state, pt, pdw_effect)
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




end -- IDROP_TARGET_INTERFACE

