indexing
	Generator: "Eiffel Emitter 2.7b2"
	external_name: "System.Windows.Forms.CheckedListBox+CheckedIndexCollection"

external class
	CHECKEDINDEXCOLLECTION_IN_SYSTEM_WINDOWS_FORMS_CHECKEDLISTBOX

inherit
	ANY
		redefine
			finalize,
			get_hash_code,
			is_equal,
			to_string
		end
	SYSTEM_COLLECTIONS_ILIST
		rename
			index_of as ilist_index_of,
			has as ilist_has,
			prune_i_th as ilist_prune_i_th,
			remove as ilist_remove,
			insert as ilist_insert,
			clear as ilist_clear,
			extend as ilist_extend,
			put_i_th as ilist_put_i_th,
			get_item as ilist_get_item,
			get_is_fixed_size as ilist_get_is_fixed_size,
			get_is_synchronized as icollection_get_is_synchronized,
			get_sync_root as icollection_get_sync_root
		end
	SYSTEM_COLLECTIONS_IENUMERABLE
	SYSTEM_COLLECTIONS_ICOLLECTION
		rename
			get_is_synchronized as icollection_get_is_synchronized,
			get_sync_root as icollection_get_sync_root
		end

create {NONE}

feature -- Access

	frozen get_item (index: INTEGER): INTEGER is
		external
			"IL signature (System.Int32): System.Int32 use System.Windows.Forms.CheckedListBox+CheckedIndexCollection"
		alias
			"get_Item"
		end

	frozen get_count: INTEGER is
		external
			"IL signature (): System.Int32 use System.Windows.Forms.CheckedListBox+CheckedIndexCollection"
		alias
			"get_Count"
		end

	frozen get_is_read_only: BOOLEAN is
		external
			"IL signature (): System.Boolean use System.Windows.Forms.CheckedListBox+CheckedIndexCollection"
		alias
			"get_IsReadOnly"
		end

feature -- Basic Operations

	get_hash_code: INTEGER is
		external
			"IL signature (): System.Int32 use System.Windows.Forms.CheckedListBox+CheckedIndexCollection"
		alias
			"GetHashCode"
		end

	frozen get_enumerator: SYSTEM_COLLECTIONS_IENUMERATOR is
		external
			"IL signature (): System.Collections.IEnumerator use System.Windows.Forms.CheckedListBox+CheckedIndexCollection"
		alias
			"GetEnumerator"
		end

	frozen has (index: INTEGER): BOOLEAN is
		external
			"IL signature (System.Int32): System.Boolean use System.Windows.Forms.CheckedListBox+CheckedIndexCollection"
		alias
			"Contains"
		end

	frozen index_of (index: INTEGER): INTEGER is
		external
			"IL signature (System.Int32): System.Int32 use System.Windows.Forms.CheckedListBox+CheckedIndexCollection"
		alias
			"IndexOf"
		end

	to_string: STRING is
		external
			"IL signature (): System.String use System.Windows.Forms.CheckedListBox+CheckedIndexCollection"
		alias
			"ToString"
		end

	frozen copy_to (dest: SYSTEM_ARRAY; index: INTEGER) is
		external
			"IL signature (System.Array, System.Int32): System.Void use System.Windows.Forms.CheckedListBox+CheckedIndexCollection"
		alias
			"CopyTo"
		end

	is_equal (obj: ANY): BOOLEAN is
		external
			"IL signature (System.Object): System.Boolean use System.Windows.Forms.CheckedListBox+CheckedIndexCollection"
		alias
			"Equals"
		end

feature {NONE} -- Implementation

	frozen ilist_put_i_th (index: INTEGER; value: ANY) is
		external
			"IL signature (System.Int32, System.Object): System.Void use System.Windows.Forms.CheckedListBox+CheckedIndexCollection"
		alias
			"System.Collections.IList.set_Item"
		end

	frozen icollection_get_sync_root: ANY is
		external
			"IL signature (): System.Object use System.Windows.Forms.CheckedListBox+CheckedIndexCollection"
		alias
			"System.Collections.ICollection.get_SyncRoot"
		end

	frozen ilist_index_of (index: ANY): INTEGER is
		external
			"IL signature (System.Object): System.Int32 use System.Windows.Forms.CheckedListBox+CheckedIndexCollection"
		alias
			"System.Collections.IList.IndexOf"
		end

	frozen ilist_remove (value: ANY) is
		external
			"IL signature (System.Object): System.Void use System.Windows.Forms.CheckedListBox+CheckedIndexCollection"
		alias
			"System.Collections.IList.Remove"
		end

	frozen ilist_extend (value: ANY): INTEGER is
		external
			"IL signature (System.Object): System.Int32 use System.Windows.Forms.CheckedListBox+CheckedIndexCollection"
		alias
			"System.Collections.IList.Add"
		end

	frozen ilist_get_item (index: INTEGER): ANY is
		external
			"IL signature (System.Int32): System.Object use System.Windows.Forms.CheckedListBox+CheckedIndexCollection"
		alias
			"System.Collections.IList.get_Item"
		end

	frozen icollection_get_is_synchronized: BOOLEAN is
		external
			"IL signature (): System.Boolean use System.Windows.Forms.CheckedListBox+CheckedIndexCollection"
		alias
			"System.Collections.ICollection.get_IsSynchronized"
		end

	frozen ilist_has (index: ANY): BOOLEAN is
		external
			"IL signature (System.Object): System.Boolean use System.Windows.Forms.CheckedListBox+CheckedIndexCollection"
		alias
			"System.Collections.IList.Contains"
		end

	frozen ilist_clear is
		external
			"IL signature (): System.Void use System.Windows.Forms.CheckedListBox+CheckedIndexCollection"
		alias
			"System.Collections.IList.Clear"
		end

	frozen ilist_get_is_fixed_size: BOOLEAN is
		external
			"IL signature (): System.Boolean use System.Windows.Forms.CheckedListBox+CheckedIndexCollection"
		alias
			"System.Collections.IList.get_IsFixedSize"
		end

	frozen ilist_prune_i_th (index: INTEGER) is
		external
			"IL signature (System.Int32): System.Void use System.Windows.Forms.CheckedListBox+CheckedIndexCollection"
		alias
			"System.Collections.IList.RemoveAt"
		end

	finalize is
		external
			"IL signature (): System.Void use System.Windows.Forms.CheckedListBox+CheckedIndexCollection"
		alias
			"Finalize"
		end

	frozen ilist_insert (index: INTEGER; value: ANY) is
		external
			"IL signature (System.Int32, System.Object): System.Void use System.Windows.Forms.CheckedListBox+CheckedIndexCollection"
		alias
			"System.Collections.IList.Insert"
		end

end -- class CHECKEDINDEXCOLLECTION_IN_SYSTEM_WINDOWS_FORMS_CHECKEDLISTBOX
