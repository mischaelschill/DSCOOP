indexing
	generator: "Eiffel Emitter 3.1rc1"
	external_name: "System.Windows.Forms.CheckBox+CheckBoxAccessibleObject"
	assembly: "System.Windows.Forms", "1.0.3300.0", "neutral", "b77a5c561934e089"

external class
	WINFORMS_CHECK_BOX_ACCESSIBLE_OBJECT_IN_WINFORMS_CHECK_BOX

inherit
	WINFORMS_BUTTON_BASE_ACCESSIBLE_OBJECT_IN_WINFORMS_BUTTON_BASE
		redefine
			get_state,
			get_role,
			get_default_action
		end
	IREFLECT
		rename
			get_underlying_system_type as system_reflection_ireflect_get_underlying_system_type,
			invoke_member as system_reflection_ireflect_invoke_member,
			get_members as system_reflection_ireflect_get_members,
			get_member as system_reflection_ireflect_get_member,
			get_properties as system_reflection_ireflect_get_properties,
			get_property as system_reflection_ireflect_get_property,
			get_fields as system_reflection_ireflect_get_fields,
			get_field as system_reflection_ireflect_get_field,
			get_methods as system_reflection_ireflect_get_methods,
			get_method as system_reflection_ireflect_get_method
		end
	ACCESS_IACCESSIBLE
		rename
			set_acc_value as accessibility_iaccessible_set_acc_value,
			set_acc_name as accessibility_iaccessible_set_acc_name,
			get_acc_value as accessibility_iaccessible_get_acc_value,
			get_acc_state as accessibility_iaccessible_get_acc_state,
			get_acc_selection as accessibility_iaccessible_get_acc_selection,
			get_acc_role as accessibility_iaccessible_get_acc_role,
			get_acc_parent as accessibility_iaccessible_get_acc_parent,
			get_acc_name as accessibility_iaccessible_get_acc_name,
			get_acc_keyboard_shortcut as accessibility_iaccessible_get_acc_keyboard_shortcut,
			get_acc_help_topic as accessibility_iaccessible_get_acc_help_topic,
			get_acc_help as accessibility_iaccessible_get_acc_help,
			get_acc_focus as accessibility_iaccessible_get_acc_focus,
			get_acc_description as accessibility_iaccessible_get_acc_description,
			get_acc_default_action as accessibility_iaccessible_get_acc_default_action,
			get_acc_child_count as accessibility_iaccessible_get_acc_child_count,
			get_acc_child as accessibility_iaccessible_get_acc_child,
			acc_select as accessibility_iaccessible_acc_select,
			acc_navigate as accessibility_iaccessible_acc_navigate,
			acc_location as accessibility_iaccessible_acc_location,
			acc_hit_test as accessibility_iaccessible_acc_hit_test,
			acc_do_default_action as accessibility_iaccessible_acc_do_default_action
		end

create
	make_winforms_check_box_accessible_object_in_winforms_check_box

feature {NONE} -- Initialization

	frozen make_winforms_check_box_accessible_object_in_winforms_check_box (owner: WINFORMS_CONTROL) is
		external
			"IL creator signature (System.Windows.Forms.Control) use System.Windows.Forms.CheckBox+CheckBoxAccessibleObject"
		end

feature -- Access

	get_default_action: SYSTEM_STRING is
		external
			"IL signature (): System.String use System.Windows.Forms.CheckBox+CheckBoxAccessibleObject"
		alias
			"get_DefaultAction"
		end

	get_state: WINFORMS_ACCESSIBLE_STATES is
		external
			"IL signature (): System.Windows.Forms.AccessibleStates use System.Windows.Forms.CheckBox+CheckBoxAccessibleObject"
		alias
			"get_State"
		end

	get_role: WINFORMS_ACCESSIBLE_ROLE is
		external
			"IL signature (): System.Windows.Forms.AccessibleRole use System.Windows.Forms.CheckBox+CheckBoxAccessibleObject"
		alias
			"get_Role"
		end

end -- class WINFORMS_CHECK_BOX_ACCESSIBLE_OBJECT_IN_WINFORMS_CHECK_BOX
