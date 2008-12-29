note
	description: "Control interfaces. Help file: "
	legal: "See notice at end of class."
	status: "See notice at end of class."
	Note: "Automatically generated by the EiffelCOM Wizard."

deferred class
	IVIEW_OBJECT_INTERFACE

inherit
	ECOM_INTERFACE

feature -- Status Report

	draw_user_precondition (dw_draw_aspect: INTEGER; lindex: INTEGER; pv_aspect: INTEGER; ptd: TAG_DVTARGETDEVICE_RECORD; hdc_target_dev: INTEGER; hdc_draw: INTEGER; lprc_bounds: X_RECTL_RECORD; lprc_wbounds: X_RECTL_RECORD): BOOLEAN
			-- User-defined preconditions for `draw'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	get_color_set_user_precondition (dw_draw_aspect: INTEGER; lindex: INTEGER; pv_aspect: INTEGER; ptd: TAG_DVTARGETDEVICE_RECORD; hic_target_dev: INTEGER; pp_color_set: CELL [TAG_LOGPALETTE_RECORD]): BOOLEAN
			-- User-defined preconditions for `get_color_set'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	freeze_user_precondition (dw_draw_aspect: INTEGER; lindex: INTEGER; pv_aspect: INTEGER; pdw_freeze: INTEGER_REF): BOOLEAN
			-- User-defined preconditions for `freeze'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	unfreeze_user_precondition (dw_freeze: INTEGER): BOOLEAN
			-- User-defined preconditions for `unfreeze'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	set_advise_user_precondition (aspects: INTEGER; advf: INTEGER; p_adv_sink: IADVISE_SINK_INTERFACE): BOOLEAN
			-- User-defined preconditions for `set_advise'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	get_advise_user_precondition (p_aspects: INTEGER_REF; p_advf: INTEGER_REF; pp_adv_sink: CELL [IADVISE_SINK_INTERFACE]): BOOLEAN
			-- User-defined preconditions for `get_advise'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

feature -- Basic Operations

	draw (dw_draw_aspect: INTEGER; 
			lindex: INTEGER; 
			pv_aspect: INTEGER; 
			ptd: TAG_DVTARGETDEVICE_RECORD; 
			hdc_target_dev: INTEGER; 
			hdc_draw: INTEGER; 
			lprc_bounds: X_RECTL_RECORD; 
			lprc_wbounds: X_RECTL_RECORD)
			-- No description available.
			-- `dw_draw_aspect' [in].  
			-- `lindex' [in].  
			-- `pv_aspect' [in].  
			-- `ptd' [in].  
			-- `hdc_target_dev' [in].  
			-- `hdc_draw' [in].  
			-- `lprc_bounds' [in].  
			-- `lprc_wbounds' [in].  
		require
			non_void_lprc_bounds: lprc_bounds /= Void
			valid_lprc_bounds: lprc_bounds.item /= default_pointer
			non_void_lprc_wbounds: lprc_wbounds /= Void
			valid_lprc_wbounds: lprc_wbounds.item /= default_pointer
			draw_user_precondition: draw_user_precondition (dw_draw_aspect, lindex, pv_aspect, ptd, hdc_target_dev, hdc_draw, lprc_bounds, lprc_wbounds)
		deferred

		end

	get_color_set (dw_draw_aspect: INTEGER; lindex: INTEGER; pv_aspect: INTEGER; ptd: TAG_DVTARGETDEVICE_RECORD; hic_target_dev: INTEGER; pp_color_set: CELL [TAG_LOGPALETTE_RECORD])
			-- No description available.
			-- `dw_draw_aspect' [in].  
			-- `lindex' [in].  
			-- `pv_aspect' [in].  
			-- `ptd' [in].  
			-- `hic_target_dev' [in].  
			-- `pp_color_set' [out].  
		require
			non_void_ptd: ptd /= Void
			valid_ptd: ptd.item /= default_pointer
			non_void_pp_color_set: pp_color_set /= Void
			get_color_set_user_precondition: get_color_set_user_precondition (dw_draw_aspect, lindex, pv_aspect, ptd, hic_target_dev, pp_color_set)
		deferred

		ensure
			valid_pp_color_set: pp_color_set.item /= Void
		end

	freeze (dw_draw_aspect: INTEGER; lindex: INTEGER; pv_aspect: INTEGER; pdw_freeze: INTEGER_REF)
			-- No description available.
			-- `dw_draw_aspect' [in].  
			-- `lindex' [in].  
			-- `pv_aspect' [in].  
			-- `pdw_freeze' [out].  
		require
			non_void_pdw_freeze: pdw_freeze /= Void
			freeze_user_precondition: freeze_user_precondition (dw_draw_aspect, lindex, pv_aspect, pdw_freeze)
		deferred

		end

	unfreeze (dw_freeze: INTEGER)
			-- No description available.
			-- `dw_freeze' [in].  
		require
			unfreeze_user_precondition: unfreeze_user_precondition (dw_freeze)
		deferred

		end

	set_advise (aspects: INTEGER; advf: INTEGER; p_adv_sink: IADVISE_SINK_INTERFACE)
			-- No description available.
			-- `aspects' [in].  
			-- `advf' [in].  
			-- `p_adv_sink' [in].  
		require
			set_advise_user_precondition: set_advise_user_precondition (aspects, advf, p_adv_sink)
		deferred

		end

	get_advise (p_aspects: INTEGER_REF; p_advf: INTEGER_REF; pp_adv_sink: CELL [IADVISE_SINK_INTERFACE])
			-- No description available.
			-- `p_aspects' [out].  
			-- `p_advf' [out].  
			-- `pp_adv_sink' [out].  
		require
			non_void_p_aspects: p_aspects /= Void
			non_void_p_advf: p_advf /= Void
			non_void_pp_adv_sink: pp_adv_sink /= Void
			get_advise_user_precondition: get_advise_user_precondition (p_aspects, p_advf, pp_adv_sink)
		deferred

		ensure
			valid_pp_adv_sink: pp_adv_sink.item /= Void
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




end -- IVIEW_OBJECT_INTERFACE

