indexing
	description: " Help file: "
	Note: "Automatically generated by the EiffelCOM Wizard."

class
	EIFFEL_COMPONENTS_PROXY

inherit
	X_EIFFEL_COMPONENTS_INTERFACE

	ECOM_QUERIABLE

creation
	make,
	make_from_other,
	make_from_pointer

feature {NONE}  -- Initialization

	make is
			-- Creation
		do
			initializer := ccom_create_eiffel_components_coclass
			item := ccom_item (initializer)
		end

	make_from_pointer (cpp_obj: POINTER) is
			-- Make from pointer
		do
			initializer := ccom_create_eiffel_components_coclass_from_pointer(cpp_obj)
			item := ccom_item (initializer)
		end

feature -- Access

	to_string: STRING is
			-- No description available.
		do
			Result := ccom_to_string (initializer)
		end

	get_hash_code: INTEGER is
			-- No description available.
		do
			Result := ccom_get_hash_code (initializer)
		end

	get_type: INTEGER is
			-- No description available.
		do
			Result := ccom_get_type (initializer)
		end

	export_clause: X_EXPORT_CLAUSE_INTERFACE is
			-- No description available.
		do
			Result := ccom_export_clause (initializer)
		end

	named_signature_type: X_NAMED_SIGNATURE_TYPE_INTERFACE is
			-- No description available.
		do
			Result := ccom_named_signature_type (initializer)
		end

	select_clause: X_SELECT_CLAUSE_INTERFACE is
			-- No description available.
		do
			Result := ccom_select_clause (initializer)
		end

	eiffel_class: X_EIFFEL_CLASS_INTERFACE is
			-- No description available.
		do
			Result := ccom_eiffel_class (initializer)
		end

	formal_named_signature_type: X_FORMAL_NAMED_SIGNATURE_TYPE_INTERFACE is
			-- No description available.
		do
			Result := ccom_formal_named_signature_type (initializer)
		end

	rename_clause: X_RENAME_CLAUSE_INTERFACE is
			-- No description available.
		do
			Result := ccom_rename_clause (initializer)
		end

	redefine_clause: X_REDEFINE_CLAUSE_INTERFACE is
			-- No description available.
		do
			Result := ccom_redefine_clause (initializer)
		end

	undefine_clause: X_UNDEFINE_CLAUSE_INTERFACE is
			-- No description available.
		do
			Result := ccom_undefine_clause (initializer)
		end

	assembly_factory: X_EIFFEL_ASSEMBLY_FACTORY_INTERFACE is
			-- No description available.
		do
			Result := ccom_assembly_factory (initializer)
		end

	x_internal_export_clause: X_EXPORT_CLAUSE_INTERFACE is
			-- No description available.
		do
			Result := ccom_x_internal_export_clause (initializer)
		end

	x_internal_named_signature_type: X_NAMED_SIGNATURE_TYPE_INTERFACE is
			-- No description available.
		do
			Result := ccom_x_internal_named_signature_type (initializer)
		end

	x_internal_select_clause: X_SELECT_CLAUSE_INTERFACE is
			-- No description available.
		do
			Result := ccom_x_internal_select_clause (initializer)
		end

	x_internal_eiffel_class: X_EIFFEL_CLASS_INTERFACE is
			-- No description available.
		do
			Result := ccom_x_internal_eiffel_class (initializer)
		end

	x_internal_formal_named_signature_type: X_FORMAL_NAMED_SIGNATURE_TYPE_INTERFACE is
			-- No description available.
		do
			Result := ccom_x_internal_formal_named_signature_type (initializer)
		end

	x_internal_rename_clause: X_RENAME_CLAUSE_INTERFACE is
			-- No description available.
		do
			Result := ccom_x_internal_rename_clause (initializer)
		end

	x_internal_redefine_clause: X_REDEFINE_CLAUSE_INTERFACE is
			-- No description available.
		do
			Result := ccom_x_internal_redefine_clause (initializer)
		end

	x_internal_undefine_clause: X_UNDEFINE_CLAUSE_INTERFACE is
			-- No description available.
		do
			Result := ccom_x_internal_undefine_clause (initializer)
		end

	x_internal_assembly_factory: X_EIFFEL_ASSEMBLY_FACTORY_INTERFACE is
			-- No description available.
		do
			Result := ccom_x_internal_assembly_factory (initializer)
		end

feature -- Basic Operations

	equals (obj: POINTER_REF): BOOLEAN is
			-- No description available.
			-- `obj' [in].  
		do
			Result := ccom_equals (initializer, obj.item)
		end

	make1 is
			-- No description available.
		do
			ccom_make1 (initializer)
		end

	set_ref__internal_export_clause (p_ret_val: X_EXPORT_CLAUSE_INTERFACE) is
			-- No description available.
			-- `p_ret_val' [in].  
		local
			p_ret_val_item: POINTER
			a_stub: ECOM_STUB
		do
			if p_ret_val /= Void then
				if (p_ret_val.item = default_pointer) then
					a_stub ?= p_ret_val
					if a_stub /= Void then
						a_stub.create_item
					end
				end
				p_ret_val_item := p_ret_val.item
			end
			ccom_set_ref__internal_export_clause (initializer, p_ret_val_item)
		end

	set_ref__internal_named_signature_type (p_ret_val: X_NAMED_SIGNATURE_TYPE_INTERFACE) is
			-- No description available.
			-- `p_ret_val' [in].  
		local
			p_ret_val_item: POINTER
			a_stub: ECOM_STUB
		do
			if p_ret_val /= Void then
				if (p_ret_val.item = default_pointer) then
					a_stub ?= p_ret_val
					if a_stub /= Void then
						a_stub.create_item
					end
				end
				p_ret_val_item := p_ret_val.item
			end
			ccom_set_ref__internal_named_signature_type (initializer, p_ret_val_item)
		end

	set_ref__internal_select_clause (p_ret_val: X_SELECT_CLAUSE_INTERFACE) is
			-- No description available.
			-- `p_ret_val' [in].  
		local
			p_ret_val_item: POINTER
			a_stub: ECOM_STUB
		do
			if p_ret_val /= Void then
				if (p_ret_val.item = default_pointer) then
					a_stub ?= p_ret_val
					if a_stub /= Void then
						a_stub.create_item
					end
				end
				p_ret_val_item := p_ret_val.item
			end
			ccom_set_ref__internal_select_clause (initializer, p_ret_val_item)
		end

	set_ref__internal_eiffel_class (p_ret_val: X_EIFFEL_CLASS_INTERFACE) is
			-- No description available.
			-- `p_ret_val' [in].  
		local
			p_ret_val_item: POINTER
			a_stub: ECOM_STUB
		do
			if p_ret_val /= Void then
				if (p_ret_val.item = default_pointer) then
					a_stub ?= p_ret_val
					if a_stub /= Void then
						a_stub.create_item
					end
				end
				p_ret_val_item := p_ret_val.item
			end
			ccom_set_ref__internal_eiffel_class (initializer, p_ret_val_item)
		end

	set_ref__internal_formal_named_signature_type (p_ret_val: X_FORMAL_NAMED_SIGNATURE_TYPE_INTERFACE) is
			-- No description available.
			-- `p_ret_val' [in].  
		local
			p_ret_val_item: POINTER
			a_stub: ECOM_STUB
		do
			if p_ret_val /= Void then
				if (p_ret_val.item = default_pointer) then
					a_stub ?= p_ret_val
					if a_stub /= Void then
						a_stub.create_item
					end
				end
				p_ret_val_item := p_ret_val.item
			end
			ccom_set_ref__internal_formal_named_signature_type (initializer, p_ret_val_item)
		end

	set_ref__internal_rename_clause (p_ret_val: X_RENAME_CLAUSE_INTERFACE) is
			-- No description available.
			-- `p_ret_val' [in].  
		local
			p_ret_val_item: POINTER
			a_stub: ECOM_STUB
		do
			if p_ret_val /= Void then
				if (p_ret_val.item = default_pointer) then
					a_stub ?= p_ret_val
					if a_stub /= Void then
						a_stub.create_item
					end
				end
				p_ret_val_item := p_ret_val.item
			end
			ccom_set_ref__internal_rename_clause (initializer, p_ret_val_item)
		end

	set_ref__internal_redefine_clause (p_ret_val: X_REDEFINE_CLAUSE_INTERFACE) is
			-- No description available.
			-- `p_ret_val' [in].  
		local
			p_ret_val_item: POINTER
			a_stub: ECOM_STUB
		do
			if p_ret_val /= Void then
				if (p_ret_val.item = default_pointer) then
					a_stub ?= p_ret_val
					if a_stub /= Void then
						a_stub.create_item
					end
				end
				p_ret_val_item := p_ret_val.item
			end
			ccom_set_ref__internal_redefine_clause (initializer, p_ret_val_item)
		end

	set_ref__internal_undefine_clause (p_ret_val: X_UNDEFINE_CLAUSE_INTERFACE) is
			-- No description available.
			-- `p_ret_val' [in].  
		local
			p_ret_val_item: POINTER
			a_stub: ECOM_STUB
		do
			if p_ret_val /= Void then
				if (p_ret_val.item = default_pointer) then
					a_stub ?= p_ret_val
					if a_stub /= Void then
						a_stub.create_item
					end
				end
				p_ret_val_item := p_ret_val.item
			end
			ccom_set_ref__internal_undefine_clause (initializer, p_ret_val_item)
		end

	set_ref__internal_assembly_factory (p_ret_val: X_EIFFEL_ASSEMBLY_FACTORY_INTERFACE) is
			-- No description available.
			-- `p_ret_val' [in].  
		local
			p_ret_val_item: POINTER
			a_stub: ECOM_STUB
		do
			if p_ret_val /= Void then
				if (p_ret_val.item = default_pointer) then
					a_stub ?= p_ret_val
					if a_stub /= Void then
						a_stub.create_item
					end
				end
				p_ret_val_item := p_ret_val.item
			end
			ccom_set_ref__internal_assembly_factory (initializer, p_ret_val_item)
		end

feature {NONE}  -- Implementation

	delete_wrapper is
			-- Delete wrapper
		do
			ccom_delete_eiffel_components_coclass(initializer)
		end

feature {NONE}  -- Externals

	ccom_to_string (cpp_obj: POINTER): STRING is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](): EIF_REFERENCE"
		end

	ccom_equals (cpp_obj: POINTER; obj: POINTER): BOOLEAN is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](VARIANT *): EIF_BOOLEAN"
		end

	ccom_get_hash_code (cpp_obj: POINTER): INTEGER is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](): EIF_INTEGER"
		end

	ccom_get_type (cpp_obj: POINTER): INTEGER is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](): EIF_INTEGER"
		end

	ccom_export_clause (cpp_obj: POINTER): X_EXPORT_CLAUSE_INTERFACE is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](): EIF_REFERENCE"
		end

	ccom_named_signature_type (cpp_obj: POINTER): X_NAMED_SIGNATURE_TYPE_INTERFACE is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](): EIF_REFERENCE"
		end

	ccom_select_clause (cpp_obj: POINTER): X_SELECT_CLAUSE_INTERFACE is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](): EIF_REFERENCE"
		end

	ccom_eiffel_class (cpp_obj: POINTER): X_EIFFEL_CLASS_INTERFACE is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](): EIF_REFERENCE"
		end

	ccom_formal_named_signature_type (cpp_obj: POINTER): X_FORMAL_NAMED_SIGNATURE_TYPE_INTERFACE is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](): EIF_REFERENCE"
		end

	ccom_rename_clause (cpp_obj: POINTER): X_RENAME_CLAUSE_INTERFACE is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](): EIF_REFERENCE"
		end

	ccom_redefine_clause (cpp_obj: POINTER): X_REDEFINE_CLAUSE_INTERFACE is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](): EIF_REFERENCE"
		end

	ccom_undefine_clause (cpp_obj: POINTER): X_UNDEFINE_CLAUSE_INTERFACE is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](): EIF_REFERENCE"
		end

	ccom_make1 (cpp_obj: POINTER) is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"]()"
		end

	ccom_assembly_factory (cpp_obj: POINTER): X_EIFFEL_ASSEMBLY_FACTORY_INTERFACE is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](): EIF_REFERENCE"
		end

	ccom_x_internal_export_clause (cpp_obj: POINTER): X_EXPORT_CLAUSE_INTERFACE is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](): EIF_REFERENCE"
		end

	ccom_set_ref__internal_export_clause (cpp_obj: POINTER; p_ret_val: POINTER) is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](ecom_ISE_Reflection_EiffelComponents::_ExportClause *)"
		end

	ccom_x_internal_named_signature_type (cpp_obj: POINTER): X_NAMED_SIGNATURE_TYPE_INTERFACE is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](): EIF_REFERENCE"
		end

	ccom_set_ref__internal_named_signature_type (cpp_obj: POINTER; p_ret_val: POINTER) is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](ecom_ISE_Reflection_EiffelComponents::_NamedSignatureType *)"
		end

	ccom_x_internal_select_clause (cpp_obj: POINTER): X_SELECT_CLAUSE_INTERFACE is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](): EIF_REFERENCE"
		end

	ccom_set_ref__internal_select_clause (cpp_obj: POINTER; p_ret_val: POINTER) is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](ecom_ISE_Reflection_EiffelComponents::_SelectClause *)"
		end

	ccom_x_internal_eiffel_class (cpp_obj: POINTER): X_EIFFEL_CLASS_INTERFACE is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](): EIF_REFERENCE"
		end

	ccom_set_ref__internal_eiffel_class (cpp_obj: POINTER; p_ret_val: POINTER) is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](ecom_ISE_Reflection_EiffelComponents::_EiffelClass *)"
		end

	ccom_x_internal_formal_named_signature_type (cpp_obj: POINTER): X_FORMAL_NAMED_SIGNATURE_TYPE_INTERFACE is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](): EIF_REFERENCE"
		end

	ccom_set_ref__internal_formal_named_signature_type (cpp_obj: POINTER; p_ret_val: POINTER) is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](ecom_ISE_Reflection_EiffelComponents::_FormalNamedSignatureType *)"
		end

	ccom_x_internal_rename_clause (cpp_obj: POINTER): X_RENAME_CLAUSE_INTERFACE is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](): EIF_REFERENCE"
		end

	ccom_set_ref__internal_rename_clause (cpp_obj: POINTER; p_ret_val: POINTER) is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](ecom_ISE_Reflection_EiffelComponents::_RenameClause *)"
		end

	ccom_x_internal_redefine_clause (cpp_obj: POINTER): X_REDEFINE_CLAUSE_INTERFACE is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](): EIF_REFERENCE"
		end

	ccom_set_ref__internal_redefine_clause (cpp_obj: POINTER; p_ret_val: POINTER) is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](ecom_ISE_Reflection_EiffelComponents::_RedefineClause *)"
		end

	ccom_x_internal_undefine_clause (cpp_obj: POINTER): X_UNDEFINE_CLAUSE_INTERFACE is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](): EIF_REFERENCE"
		end

	ccom_set_ref__internal_undefine_clause (cpp_obj: POINTER; p_ret_val: POINTER) is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](ecom_ISE_Reflection_EiffelComponents::_UndefineClause *)"
		end

	ccom_x_internal_assembly_factory (cpp_obj: POINTER): X_EIFFEL_ASSEMBLY_FACTORY_INTERFACE is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](): EIF_REFERENCE"
		end

	ccom_set_ref__internal_assembly_factory (cpp_obj: POINTER; p_ret_val: POINTER) is
			-- No description available.
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](ecom_ISE_Reflection_EiffelComponents::_EiffelAssemblyFactory *)"
		end

	ccom_create_eiffel_components_coclass: POINTER is
			-- Creation
		external
			"C++ [new ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"]()"
		end

	ccom_delete_eiffel_components_coclass (a_pointer: POINTER) is
			-- Release resource
		external
			"C++ [delete ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"]()"
		end

	ccom_create_eiffel_components_coclass_from_pointer (a_pointer: POINTER): POINTER is
			-- Create from pointer
		external
			"C++ [new ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"](IUnknown *)"
		end

	ccom_item (cpp_obj: POINTER): POINTER is
			-- Item
		external
			"C++ [ecom_ISE_Reflection_EiffelComponents::EiffelComponents %"ecom_ISE_Reflection_EiffelComponents_EiffelComponents.h%"]():EIF_POINTER"
		end

end -- EIFFEL_COMPONENTS_PROXY

