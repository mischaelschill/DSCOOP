indexing
	description: "Constants for generator"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WIZARD_GENERATOR_CONSTANTS

feature -- Access

	Class_footer: STRING is ""

	Class_header: STRING is ""

	Description_keyword: STRING is "description"

	Note_keyword: STRING is "Note"

	None_keyword: STRING is "NONE"

	Wizard_note: STRING is "%"Automatically generated by the EiffelCOM Wizard.%""

	Initialization_title: STRING is "Initialization"

	Access_title: STRING is "Access"

	Measurement_title: STRING is "Measurement"

	Status_report_title: STRING is "Status Report"

	Element_change_title: STRING is "Element Change"

	Basic_operations_title: STRING is "Basic Operations"

	Implementation_title: STRING is "Implementation"

	External_title: STRING is "External"

	Added:STRING is "Added"

	Dynamic_type_function_name: STRING is "dynamic_type"

	Processed: STRING is "Processed"

	Processing: STRING is "Processing"

	Record: STRING is "Record"

	Elements_string: STRING is "Elements"

	Inherit_from_string: STRING is   "inherit from"

	Dispinterface_string: STRING is "Dispinterface"

	Interface: STRING is "Interface"

	Coclass: STRING is "Coclass"

	Enumerator: STRING is "Enumerator"

	Functions_string: STRING is "Functions"

	Properties_string: STRING is "Properties"

	Precondition_function_comment: STRING is "User-defined preconditions for "

	Should_redefine: STRING is "Redefine in descendants if needed."

	Implemented_word: STRING is "implemented"

	implemented_coclass_extension: STRING is "_IMP"

	Register_dll_server_function_name: STRING is "dll_register_server"

	Unregister_dll_server_function_name: STRING is "dll_unregister_server"

	Can_unload_dll_now_function_name: STRING is "dll_can_unload_now"

	Get_class_object_function_name: STRING is "dll_get_class_object"

	Ccom_get_class_object_function_name: STRING is "ccom_class_object"

	Ccom_register_dll_server_function_name: STRING is "ccom_register_dll_server"

	Ccom_unregister_dll_server_function_name: STRING is "ccom_unregister_dll_server"

	Ccom_can_unload_dll_now_function_name: STRING is "ccom_dll_can_unload_now"

	Excepinfo_access: STRING is "excepinfo->"

	Excepinfo_variable_name: STRING is "excepinfo"

	Wcode_field: STRING is "wCode"

	Default_iunknown_variable_comment: STRING is "Default IUnknown interface pointer"

	Excepinfo_variable_comment: STRING is "Exception information"

	Bstr_source_field: STRING is "bstrSource"

	Server_registration_header_file_name: STRING is "server_registration.h"

	Ccom_embedding_feature_name: STRING is "ccom_embedding"

	Ccom_regserver_feature_name: STRING is "ccom_register_server"

	Ccom_unregserver_feature_name: STRING is "ccom_unregister_server"

	Embedding_feature_name: STRING is "embedding"

	Regserver_feature_name: STRING is "regserver"

	Unregserver_feature_name: STRING is "unregserver"

	Bstr_description_field: STRING is "bstrDescription"

	Bstr_help_file_field: STRING is "bstrHelpFile"

	Class_object_registration_token: STRING is "dwRegister"

	Class_object_variable_name: STRING is "cls_object"

	Tmp_eif_object: STRING is "tmp_eif_object"

	Option_variable_name: STRING is "an_option"

	Locks_variable_name: STRING is "lock_count"

	Delete_on_unregister: STRING is "pDelOnUnregister"

	Key_name: STRING is "pKeyName"

	Struct_value: STRING is "pValue"

	Value_name: STRING is "pValueName"

	Reg_data: STRING is "REG_DATA"

	Registry_entries_variable_name: STRING is "reg_entries"

	Component_entries_count: STRING is "com_entries_count"

	Extern_lock_module: STRING is "extern void LockModule (void);"

	Extern_unlock_module: STRING is "extern void UnlockModule (void);"

	Eiffel_object: STRING is "eiffel_object"

	Set_type_id_function_name: STRING is "set_type_id"

	Ecatch: STRING is "%TECATCH;%N"

	Eif_initialize_aux_thread: STRING is "%TEIF_INITIALIZE_AUX_THREAD;%N"

	ecom_enter_stub: STRING is "%TECOM_ENTER_STUB;%N"

	Ecatch_auto: STRING is "ECATCH_AUTO"

	End_ecatch: STRING is "END_ECATCH;%N%T"

	ecom_exit_stub: STRING is "ECOM_EXIT_STUB;%N%T"

	Lock_module_function: STRING is "LockModule ();"

	Unlock_module_function: STRING is "UnlockModule ();"

	Riid: STRING is "riid"

	Factory: STRING is "factory"

	Tmp_object_pointer: STRING is "pUnknown"

	Star_ppv: STRING is "*ppv"

	Query_interface_signature: STRING is "REFIID riid, void ** ppv"

	Ref_count: STRING is "ref_count"

	Tmp_variable_name: STRING is "tmp_value"

	Eiffel_procedure_variable_name: STRING is "eiffel_procedure"

	Eiffel_function_variable_name: STRING is "eiffel_function"

	Argument_name: STRING is "a_value"

	Dispparam_parameter: STRING is "pDispParams"

	Variant_parameter: STRING is "lcl_rgvarg"

	Return_value_name: STRING is "ret_value"

	Struct_selection_operator: STRING is "->"

	Ce_boolean: STRING is "ccom_ce_boolean"

	Index_of_word_option_function_name: STRING is "index_of_word_option"

	Interface_pointer_comment: STRING is "Interface pointer"

	Release_function: STRING is "->Release ();"

	Release: STRING is "Release"

	Load_type_lib: STRING is "LoadTypeLib"

	Return_s_ok: STRING is "return S_OK;"

	Get_type_info_of_guid: STRING is "GetTypeInfoOfGuid"

	Get_ids_of_names: STRING is "GetIDsOfNames"

	Get_type_info: STRING is "GetTypeInfo"

	Get_type_info_count: STRING is "GetTypeInfoCount"

	Add_reference: STRING is "AddRef"

	Add_reference_function: STRING is "->AddRef ();"

	Query_interface: STRING  is "QueryInterface"

	Co_uninitialize_function: STRING is "CoUninitialize ();"

	Interface_variable_prepend: STRING is "p_"

	Initialize_function_name: STRING is "initialize"

	Zero: STRING is "0"

	Type_info_variable_name: STRING is "pTypeInfo"

	Arguments_name: STRING is "arguments"

	One: STRING is "1"

	Multi_qi: STRING is "MULTI_QI"

	Ccom_item_function_name: STRING is "ccom_item"

	Current_object_variable_name: STRING is "current_object"

	Server_info_access: STRING is "server_info->"

	Server_info_variable: STRING is "server_info"

	Iunknown_variable_name: STRING is "p_unknown"

	Idispatch_variable_name: STRING is "p_dispatch"

	Invoke: STRING is "Invoke"

	Iunknown_clsid: STRING is "IID_IUnknown"

	Hresult_variable: STRING is "HRESULT hr = 0;%N"

	Routine_clause: STRING is "_routine"

	Append_tid_clause: STRING is "_tid"

	Feature_clause: STRING is "_feature"

	Set_item_procedure_name: STRING is "set_item"

	Put_procedure_name: STRING is "put"

	Module_file_name: STRING is "file_name"

	Wide_string_module_file_name: STRING is "ws_file_name"

	Max_path: STRING is "MAX_PATH"

	Arguments_variable_name: STRING is "arguments"

	Deferred_class_clause: STRING is "deferred class"

	Iunknown_interface: STRING is "ECOM_IUNKNOWN_INTERFACE"

	Empty_function_body: STRING is "%T%T%T-- Put Implementation here."

	Exception_body: STRING is "%T%T%Ttrigger (E_notimpl)"

	Result_clause: STRING is "Result := "

	Item_parameter_clause: STRING is "(item)"

	To_c_function: STRING is "to_c"

	Item_clause: STRING is "item"

	Array_item: STRING is "array_item"

	Make_word: STRING is "make"

	Make_from_other: STRING is "make_from_other"

	Make_from_pointer: STRING is "make_from_pointer"

	An_item_variable: STRING is "an_item"

	Current_item_variable: STRING is "current_item: POINTER"

	Null_coclass_test: STRING is "if (eiffel_coclass == NULL)%<%N"

	Type_id_variable: STRING is "EIF_TYPE_ID tid = -1;%N"

	Type_id_variable_name: STRING is "tid"

	Eif_procedure_variable: STRING is "EIF_PROCEDURE p_make;%N"

	Make_procedure: STRING is "p_make = eif_procedure (%"make_from_pointer%", tid)%N"

	Create_eiffel_object: STRING is "eiffel_object = eif_create (tid);%N"

	Tmp_clause: STRING is "tmp_"

	Get_clause: STRING is "get_"

	Register: STRING is "Register"

	Export_dll_class_name: STRING is "EXPORT_DLL_FEATURES"

	Unregister: STRING is "Unregister"

	Set_clause: STRING is "set_"

	Make_function: STRING is ".make "

	Ccom_clause: STRING is "ccom_"

	Item_function: STRING is ".item"

	Interface_function: STRING is ".interface"

	Ecom_date_type: STRING is "ECOM_DATE"

	Any_clause: STRING is "an_any: "

	Cpp_clause: STRING is "C++ %("

	Initializer_variable: STRING is "initializer"

	Pointer_variable: STRING is "a_pointer: POINTER"

	Default_pointer_argument: STRING is "a_object: POINTER"

	Empty_dispparams: STRING is "DISPPARAMS args = %<NULL, NULL, 0, 0%>;"

	Return_variant_variable: STRING is "VARIANT pResult; %N%TVariantInit (&pResult);"

	Return_variant_variable_name: STRING is "pResult"

	Hresult_variable_name: STRING is "hr"

	Hresult_variable_name_2: STRING is "hr2"

	Type_id: STRING is "type_id"

	Eif_object_variable: STRING is "eif_object"

	A_pointer: STRING is "a_pointer"

	Eif_ref_variable: STRING is "eif_ref"

	Format_message: STRING is "c_format_message"

	Com_eraise: STRING is "com_eraise"

	Beginning_comment_paramflag: STRING is " /* %("

	End_comment_paramflag: STRING is "%) */ "

	C_result: STRING is "result"

	Message_variable_name: STRING is "msg"

	Eif_eiffel_h: STRING is "eif_eiffel.h"

	Eif_com_h: STRING is "eif_com.h"

	Eif_setup_h: STRING is "eif_setup.h"

	Eif_macros_h: STRING is "eif_macros.h"

	Windows_h: STRING is "windows.h"

	Objbase_h: STRING is "objbase.h"

	Ecom_server_rt_globals_h: STRING is "ecom_server_rt_globals.h"

	An_object: STRING is "an_object"

	Eif_array: STRING is "eif_array"

	An_array: STRING is "an_array"

	Array_word: STRING is "array"

	Count_word: STRING is "count"

	A_count_word: STRING is "a_count"

	An_element: STRING is "an_element"

	A_ref: STRING is "a_ref"

	Last_error_code: STRING is "last_error_code"

	Last_error_description: STRING is "last_error_description"

	Last_error_help_file: STRING is "last_error_help_file"

	Last_source_of_exception: STRING is "last_source_of_exception"

	Ccom_last_error_code: STRING is "ccom_last_error_code"

	Ccom_last_error_description: STRING is "ccom_last_error_description"

	Ccom_last_error_help_file: STRING is "ccom_last_error_help_file"

	Ccom_last_source_of_exception: STRING is "ccom_last_source_of_exception"

	Ptr: STRING is "Pointed Type"

	Pure_virtual_sufix: STRING is " = 0"

	C_open_comment_line: STRING is "/*-----------------------------------------------------------"

	C_close_comment_line: STRING is "-----------------------------------------------------------*/";


indexing
	copyright:	"Copyright (c) 1984-2006, Eiffel Software"
	license:	"GPL version 2 (see http://www.eiffel.com/licensing/gpl.txt)"
	licensing_options:	"http://www.eiffel.com/licensing"
	copying: "[
			This file is part of Eiffel Software's Eiffel Development Environment.
			
			Eiffel Software's Eiffel Development Environment is free
			software; you can redistribute it and/or modify it under
			the terms of the GNU General Public License as published
			by the Free Software Foundation, version 2 of the License
			(available at the URL listed under "license" above).
			
			Eiffel Software's Eiffel Development Environment is
			distributed in the hope that it will be useful,	but
			WITHOUT ANY WARRANTY; without even the implied warranty
			of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
			See the	GNU General Public License for more details.
			
			You should have received a copy of the GNU General Public
			License along with Eiffel Software's Eiffel Development
			Environment; if not, write to the Free Software Foundation,
			Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA
		]"
	source: "[
			 Eiffel Software
			 356 Storke Road, Goleta, CA 93117 USA
			 Telephone 805-685-1006, Fax 805-685-6869
			 Website http://www.eiffel.com
			 Customer support http://support.eiffel.com
		]"
end -- class WIZARD_GENERATOR_CONSTANTS

