indexing
	description: "Implemented `IEnumIncludePaths' Interface."
	Note: "Automatically generated by the EiffelCOM Wizard."

class
	IENUM_INCLUDE_PATHS_IMPL_PROXY

inherit
	IENUM_INCLUDE_PATHS_INTERFACE

	ECOM_QUERIABLE

creation
	make_from_other,
	make_from_pointer

feature {NONE}  -- Initialization

	make_from_pointer (cpp_obj: POINTER) is
			-- Make from pointer
		do
			initializer := ccom_create_ienum_include_paths_impl_proxy_from_pointer(cpp_obj)
			item := ccom_item (initializer)
		end

feature -- Access

	count: INTEGER is
			-- No description available.
		do
			Result := ccom_count (initializer)
		end

feature -- Basic Operations

	next (rgelt: CELL [STRING]; pcelt_fetched: INTEGER_REF) is
			-- No description available.
			-- `rgelt' [out].  
			-- `pcelt_fetched' [out].  
		do
			ccom_next (initializer, rgelt, pcelt_fetched)
		end

	skip (celt: INTEGER) is
			-- No description available.
			-- `celt' [in].  
		do
			ccom_skip (initializer, celt)
		end

	reset is
			-- No description available.
		do
			ccom_reset (initializer)
		end

	clone1 (ppenum: CELL [IENUM_INCLUDE_PATHS_INTERFACE]) is
			-- No description available.
			-- `ppenum' [out].  
		do
			ccom_clone1 (initializer, ppenum)
		end

	ith_item (an_index: INTEGER; rgelt: CELL [STRING]) is
			-- No description available.
			-- `an_index' [in].  
			-- `rgelt' [out].  
		do
			ccom_ith_item (initializer, an_index, rgelt)
		end

feature {NONE}  -- Implementation

	delete_wrapper is
			-- Delete wrapper
		do
			ccom_delete_ienum_include_paths_impl_proxy(initializer)
		end

feature {NONE}  -- Externals

	ccom_next (cpp_obj: POINTER; rgelt: CELL [STRING]; pcelt_fetched: INTEGER_REF) is
			-- No description available.
		external
			"C++ [ecom_EiffelComCompiler::IEnumIncludePaths_impl_proxy %"ecom_EiffelComCompiler_IEnumIncludePaths_impl_proxy_s.h%"](EIF_OBJECT,EIF_OBJECT)"
		end

	ccom_skip (cpp_obj: POINTER; celt: INTEGER) is
			-- No description available.
		external
			"C++ [ecom_EiffelComCompiler::IEnumIncludePaths_impl_proxy %"ecom_EiffelComCompiler_IEnumIncludePaths_impl_proxy_s.h%"](EIF_INTEGER)"
		end

	ccom_reset (cpp_obj: POINTER) is
			-- No description available.
		external
			"C++ [ecom_EiffelComCompiler::IEnumIncludePaths_impl_proxy %"ecom_EiffelComCompiler_IEnumIncludePaths_impl_proxy_s.h%"]()"
		end

	ccom_clone1 (cpp_obj: POINTER; ppenum: CELL [IENUM_INCLUDE_PATHS_INTERFACE]) is
			-- No description available.
		external
			"C++ [ecom_EiffelComCompiler::IEnumIncludePaths_impl_proxy %"ecom_EiffelComCompiler_IEnumIncludePaths_impl_proxy_s.h%"](EIF_OBJECT)"
		end

	ccom_ith_item (cpp_obj: POINTER; an_index: INTEGER; rgelt: CELL [STRING]) is
			-- No description available.
		external
			"C++ [ecom_EiffelComCompiler::IEnumIncludePaths_impl_proxy %"ecom_EiffelComCompiler_IEnumIncludePaths_impl_proxy_s.h%"](EIF_INTEGER,EIF_OBJECT)"
		end

	ccom_count (cpp_obj: POINTER): INTEGER is
			-- No description available.
		external
			"C++ [ecom_EiffelComCompiler::IEnumIncludePaths_impl_proxy %"ecom_EiffelComCompiler_IEnumIncludePaths_impl_proxy_s.h%"](): EIF_INTEGER"
		end

	ccom_delete_ienum_include_paths_impl_proxy (a_pointer: POINTER) is
			-- Release resource
		external
			"C++ [delete ecom_EiffelComCompiler::IEnumIncludePaths_impl_proxy %"ecom_EiffelComCompiler_IEnumIncludePaths_impl_proxy_s.h%"]()"
		end

	ccom_create_ienum_include_paths_impl_proxy_from_pointer (a_pointer: POINTER): POINTER is
			-- Create from pointer
		external
			"C++ [new ecom_EiffelComCompiler::IEnumIncludePaths_impl_proxy %"ecom_EiffelComCompiler_IEnumIncludePaths_impl_proxy_s.h%"](IUnknown *)"
		end

	ccom_item (cpp_obj: POINTER): POINTER is
			-- Item
		external
			"C++ [ecom_EiffelComCompiler::IEnumIncludePaths_impl_proxy %"ecom_EiffelComCompiler_IEnumIncludePaths_impl_proxy_s.h%"]():EIF_POINTER"
		end

end -- IENUM_INCLUDE_PATHS_IMPL_PROXY

