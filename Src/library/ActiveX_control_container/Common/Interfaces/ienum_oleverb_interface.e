note
	description: "Control interfaces. Help file: "
	legal: "See notice at end of class."
	status: "See notice at end of class."
	Note: "Automatically generated by the EiffelCOM Wizard."

deferred class
	IENUM_OLEVERB_INTERFACE

inherit
	ECOM_INTERFACE

feature -- Status Report

	next_user_precondition (celt: INTEGER; rgelt: ARRAY [TAG_OLEVERB_RECORD]; pcelt_fetched: INTEGER_REF): BOOLEAN
			-- User-defined preconditions for `next'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	skip_user_precondition (celt: INTEGER): BOOLEAN
			-- User-defined preconditions for `skip'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	reset_user_precondition: BOOLEAN
			-- User-defined preconditions for `reset'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

	clone1_user_precondition (ppenum: CELL [IENUM_OLEVERB_INTERFACE]): BOOLEAN
			-- User-defined preconditions for `clone1'.
			-- Redefine in descendants if needed.
		do
			Result := True
		end

feature -- Basic Operations

	next (celt: INTEGER; rgelt: ARRAY [TAG_OLEVERB_RECORD]; pcelt_fetched: INTEGER_REF)
			-- No description available.
			-- `celt' [in].  
			-- `rgelt' [out].  
			-- `pcelt_fetched' [out].  
		require
			non_void_rgelt: rgelt /= Void
			non_void_pcelt_fetched: pcelt_fetched /= Void
			next_user_precondition: next_user_precondition (celt, rgelt, pcelt_fetched)
		deferred

		end

	skip (celt: INTEGER)
			-- No description available.
			-- `celt' [in].  
		require
			skip_user_precondition: skip_user_precondition (celt)
		deferred

		end

	reset
			-- No description available.
		require
			reset_user_precondition: reset_user_precondition
		deferred

		end

	clone1 (ppenum: CELL [IENUM_OLEVERB_INTERFACE])
			-- No description available.
			-- `ppenum' [out].  
		require
			non_void_ppenum: ppenum /= Void
			clone1_user_precondition: clone1_user_precondition (ppenum)
		deferred

		ensure
			valid_ppenum: ppenum.item /= Void
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




end -- IENUM_OLEVERB_INTERFACE

