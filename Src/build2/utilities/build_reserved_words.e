indexing
	description: "Objects that provide access to all Build reserved words."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	BUILD_RESERVED_WORDS

feature -- Access

	build_reserved_words: HASH_TABLE [STRING, STRING] is
			-- `Result' is reserved words specific to Build.
			-- For example, as we may inherit EV_TITLED_WINDOW,
			-- it is not valid to name an attribute or event that will
			-- clash with any of the features.
		once
			create Result.make (0)
			Result.put ("clone", "clone")
			Result.put ("conforms_to", "conforms_to")
			Result.put ("consistent", "consistent")
			Result.put ("deep_clone", "deep_clone")
			Result.put ("deep_copy", "deep_copy")
			Result.put ("deep_equal", "deep_equal")
			Result.put ("default", "default")
			Result.put ("default_pointer", "default_pointer")
			Result.put ("default_rescue", "default_rescue")
			Result.put ("do_nothing", "do_nothing")
			Result.put ("equal", "equal")
			Result.put ("generating_type", "generating_type")
			Result.put ("generator", "generator")
			Result.put ("internal_correct_mismatch", "internal_correct_mismatch")
			Result.put ("io", "io")
			Result.put ("is_equal", "is_equal")
			Result.put ("operating_environment", "operating_environment")
			Result.put ("out", "out")
			Result.put ("print", "print")
			Result.put ("same_type", "same_type")
			Result.put ("setup", "setup")
			Result.put ("standard_clone", "standard_clone")
			Result.put ("standard_copy", "standard_copy")
			Result.put ("standard_equal", "standard_equal")
			Result.put ("standard_is_equal", "standard_is_equal")
			Result.put ("standard_twin", "standard_twin")
			Result.put ("tagged_out", "tagged_out")
			Result.put ("dock_ended_actions", "dock_ended_actions")
			Result.put ("dock_started_actions", "dock_started_actions")
			Result.put ("docked_actions", "docked_actions")
			Result.put ("conforming_pick_actions", "conforming_pick_actions")
			Result.put ("drop_actions", "drop_actions")
			Result.put ("pick_actions", "pick_actions")
			Result.put ("pick_ended_actions", "pick_ended_actions")
			Result.put ("close_request_actions", "close_request_actions")
			Result.put ("move_actions", "move_actions")
			Result.put ("show_actions", "show_actions")
			Result.put ("focus_in_actions", "focus_in_actions")
			Result.put ("focus_out_actions", "focus_out_actions")
			Result.put ("key_press_actions", "key_press_actions")
			Result.put ("key_press_string_actions", "key_press_string_actions")
			Result.put ("key_release_actions", "key_release_actions")
			Result.put ("pointer_button_press_actions", "pointer_button_press_actions")
			Result.put ("pointer_button_release_actions", "pointer_button_release_actions")
			Result.put ("pointer_double_press_actions", "pointer_double_press_actions")
			Result.put ("pointer_enter_actions", "pointer_enter_actions")
			Result.put ("pointer_leave_actions", "pointer_leave_actions")
			Result.put ("pointer_motion_actions", "pointer_motion_actions")
			Result.put ("resize_actions", "resize_actions")
			Result.put ("maximize_actions", "maximize_actions")
			Result.put ("minimize_actions", "minimize_actions")
			Result.put ("restore_actions", "restore_actions")
			Result.put ("compare_objects", "compare_objects")
			Result.put ("compare_references", "compare_references")
			Result.put ("empty", "empty")
			Result.put ("fill", "fill")
			Result.put ("is_inserted", "is_inserted")
			Result.put ("prune_all", "prune_all")
			Result.put ("allocate_compact", "allocate_compact")
			Result.put ("allocate_fast", "allocate_fast")
			Result.put ("allocate_tiny", "allocate_tiny")
			Result.put ("chunk_size", "chunk_size")
			Result.put ("coalesce_period", "coalesce_period")
			Result.put ("collect", "collect")
			Result.put ("collecting", "collecting")
			Result.put ("collection_off", "collection_off")
			Result.put ("collection_on", "collection_on")
			Result.put ("collection_period", "collection_period")
			Result.put ("disable_time_accounting", "disable_time_accounting")
			Result.put ("enable_time_accounting", "enable_time_accounting")
			Result.put ("find_instance_of", "find_instance_of")
			Result.put ("find_referers", "find_referers")
			Result.put ("free", "free")
			Result.put ("full_coalesce", "full_coalesce")
			Result.put ("full_collect", "full_collect")
			Result.put ("gc_monitoring", "gc_monitoring")
			Result.put ("gc_statistics", "gc_statistics")
			Result.put ("generation_object_limit", "generation_object_limit")
			Result.put ("is_in_final_collect", "is_in_final_collect")
			Result.put ("largest_coalesced_block", "largest_coalesced_block")
			Result.put ("max_mem", "max_mem")
			Result.put ("mem_free", "mem_free")
			Result.put ("memory_statistics", "memory_statistics")
			Result.put ("memory_threshold", "memory_threshold")
			Result.put ("objects_instance_of", "objects_instance_of")
			Result.put ("referers", "referers")
			Result.put ("scavenge_zone_size", "scavenge_zone_size")
			Result.put ("set_coalesce_period", "set_coalesce_period")
			Result.put ("set_collection_period", "set_collection_period")
			Result.put ("set_max_mem", "set_max_mem")
			Result.put ("set_memory_threshold", "set_memory_threshold")
			Result.put ("tenure", "tenure")
			Result.put ("application_exists", "application_exists")
			Result.put ("copy", "copy")
			Result.put ("default_create", "default_create")
			Result.put ("destroy", "destroy")
			Result.put ("is_destroyed", "is_destroyed")
			Result.put ("is_usable", "is_usable")
			Result.put ("replace_implementation", "replace_implementation")
			Result.put ("set_data", "set_data")
			Result.put ("help_context", "help_context")
			Result.put ("remove_help_context", "remove_help_context")
			Result.put ("set_help_context", "set_help_context")
			Result.put ("disable_dockable", "disable_dockable")
			Result.put ("disable_external_docking", "disable_external_docking")
			Result.put ("enable_dockable", "enable_dockable")
			Result.put ("enable_external_docking", "enable_external_docking")
			Result.put ("is_dockable", "is_dockable")
			Result.put ("is_external_docking_enabled", "is_external_docking_enabled")
			Result.put ("parent_of_source_allows_docking", "parent_of_source_allows_docking")
			Result.put ("real_source", "real_source")
			Result.put ("remove_real_source", "remove_real_source")
			Result.put ("set_real_source", "set_real_source")
			Result.put ("source_has_current_recursive", "source_has_current_recursive")
			Result.put ("height", "height")
			Result.put ("minimum_height", "minimum_height")
			Result.put ("minimum_width", "minimum_width")
			Result.put ("width", "width")
			Result.put ("x_position", "x_position")
			Result.put ("y_position", "y_position")
			Result.put ("set_height", "set_height")
			Result.put ("set_position", "set_position")
			Result.put ("set_size", "set_size")
			Result.put ("set_width", "set_width")
			Result.put ("set_x_position", "set_x_position")
			Result.put ("set_y_position", "set_y_position")
			Result.put ("background_color", "background_color")
			Result.put ("foreground_color", "foreground_color")
			Result.put ("set_background_color", "set_background_color")
			Result.put ("set_default_colors", "set_default_colors")
			Result.put ("set_foreground_color", "set_foreground_color")
			Result.put ("remove_background_pixmap", "remove_background_pixmap")
			Result.put ("set_background_pixmap", "set_background_pixmap")
			Result.put ("set_pixmap_path", "set_pixmap_path")
			Result.put ("disable_sensitive", "disable_sensitive")
			Result.put ("enable_sensitive", "enable_sensitive")
			Result.put ("is_sensitive", "is_sensitive")
			Result.put ("parent_is_sensitive", "parent_is_sensitive")
			Result.put ("dispose", "dispose")
			Result.put ("eif_id_object", "eif_id_object")
			Result.put ("eif_object_id", "eif_object_id")
			Result.put ("eif_object_id_free", "eif_object_id_free")
			Result.put ("free_id", "free_id")
			Result.put ("id_freed", "id_freed")
			Result.put ("id_object", "id_object")
			Result.put ("object_id", "object_id")
			Result.put ("init_drop_actions", "init_drop_actions")
			Result.put ("set_target_name", "set_target_name")
			Result.put ("accept_cursor", "accept_cursor")
			Result.put ("deny_cursor", "deny_cursor")
			Result.put ("disable_pebble_positioning", "disable_pebble_positioning")
			Result.put ("enable_pebble_positioning", "enable_pebble_positioning")
			Result.put ("mode_is_drag_and_drop", "mode_is_drag_and_drop")
			Result.put ("mode_is_pick_and_drop", "mode_is_pick_and_drop")
			Result.put ("mode_is_target_menu", "mode_is_target_menu")
			Result.put ("pebble", "pebble")
			Result.put ("pebble_function", "pebble_function")
			Result.put ("pebble_positioning_enabled", "pebble_positioning_enabled")
			Result.put ("pebble_x_position", "pebble_x_position")
			Result.put ("pebble_y_position", "pebble_y_position")
			Result.put ("remove_pebble", "remove_pebble")
			Result.put ("set_accept_cursor", "set_accept_cursor")
			Result.put ("set_deny_cursor", "set_deny_cursor")
			Result.put ("set_drag_and_drop_mode", "set_drag_and_drop_mode")
			Result.put ("set_pebble", "set_pebble")
			Result.put ("set_pebble_function", "set_pebble_function")
			Result.put ("set_pebble_position", "set_pebble_position")
			Result.put ("set_pick_and_drop_mode", "set_pick_and_drop_mode")
			Result.put ("set_target_menu_mode", "set_target_menu_mode")
			Result.put ("actual_drop_target_agent", "actual_drop_target_agent")
			Result.put ("center_pointer", "center_pointer")
			Result.put ("Default_pixmaps", "Default_pixmaps")
			Result.put ("disable_capture", "disable_capture")
			Result.put ("enable_capture", "enable_capture")
			Result.put ("has_capture", "has_capture")
			Result.put ("has_focus", "has_focus")
			Result.put ("hide", "hide")
			Result.put ("is_displayed", "is_displayed")
			Result.put ("is_show_requested", "is_show_requested")
			Result.put ("parent", "parent")
			Result.put ("pointer_position", "pointer_position")
			Result.put ("pointer_style", "pointer_style")
			Result.put ("real_target", "real_target")
			Result.put ("remove_real_target", "remove_real_target")
			Result.put ("reset_minimum_height", "reset_minimum_height")
			Result.put ("reset_minimum_width", "reset_minimum_width")
			Result.put ("screen_x", "screen_x")
			Result.put ("screen_y", "screen_y")
			Result.put ("set_actual_drop_target_agent", "set_actual_drop_target_agent")
			Result.put ("set_focus", "set_focus")
			Result.put ("set_minimum_height", "set_minimum_height")
			Result.put ("set_minimum_size", "set_minimum_size")
			Result.put ("set_minimum_width", "set_minimum_width")
			Result.put ("set_pointer_style", "set_pointer_style")
			Result.put ("set_real_target", "set_real_target")
			Result.put ("show", "show")
			Result.put ("all_radio_buttons_connected", "all_radio_buttons_connected")
			Result.put ("background_color_propagated", "background_color_propagated")
			Result.put ("background_pixmap", "background_pixmap")
			Result.put ("cl_put", "cl_put")
			Result.put ("cl_put", "cl_put")
			Result.put ("client_height", "client_height")
			Result.put ("lient_width", "client_width")
			Result.put ("put", "put")
			Result.put ("first_radio_button_selected", "first_radio_button_selected")
			Result.put ("foreground_color_propagated", "foreground_color_propagated")
			Result.put ("has_radio_button", "has_radio_button")
			Result.put ("has_recursive", "has_recursive")
			Result.put ("has_selected_radio_button", "has_selected_radio_button")
			Result.put ("is_parent_recursive", "is_parent_recursive")
			Result.put ("item", "item")
			Result.put ("items_unique", "items_unique")
			Result.put ("may_contain", "may_contain")
			Result.put ("merge_radio_button_groups", "merge_radio_button_groups")
			Result.put ("merged_radio_button_groups", "merged_radio_button_groups")
			Result.put ("parent_of_items_is_current", "parent_of_items_is_current")
			Result.put ("propagate_background_color", "propagate_background_color")
			Result.put ("propagate_foreground_color", "propagate_foreground_color")
			Result.put ("put", "put")
			Result.put ("replace", "replace")
			Result.put ("unmerge_radio_button_groups", "unmerge_radio_button_groups")
			Result.put ("disable_docking", "disable_docking")
			Result.put ("enable_docking", "enable_docking")
			Result.put ("is_docking_enabled", "is_docking_enabled")
			Result.put ("set_veto_dock_function", "set_veto_dock_function")
			Result.put ("veto_dock_function", "veto_dock_function")
			Result.put ("count", "count")
			Result.put ("extendible", "extendible")
			Result.put ("full", "full")
			Result.put ("is_empty", "is_empty")
			Result.put ("", "linear_representation")
			Result.put ("linear_representation", "prunable")
			Result.put ("prune", "prune")
			Result.put ("readable", "readable")
			Result.put ("wipe_out", "wipe_out")
			Result.put ("writable", "writable")
			Result.put ("disable_user_resize", "disable_user_resize")
			Result.put ("enable_user_resize", "enable_user_resize")
			Result.put ("has", "has")
			Result.put ("is_in_default_state", "is_in_default_state")
			Result.put ("lock_update", "lock_update")
			Result.put ("lower_bar", "lower_bar")
			Result.put ("make_with_title", "make_with_title")
			Result.put ("maximum_height", "maximum_height")
			Result.put ("maximum_width", "maximum_width")
			Result.put ("menu_bar", "menu_bar")
			Result.put ("remove_menu_bar", "remove_menu_bar")
			Result.put ("remove_title", "remove_title")
			Result.put ("set_maximum_height", "set_maximum_height")
			Result.put ("set_maximum_size", "set_maximum_size")
			Result.put ("set_maximum_width", "set_maximum_width")
			Result.put ("set_menu_bar", "set_menu_bar")
			Result.put ("set_title", "set_title")
			Result.put ("title", "title")
			Result.put ("unlock_update", "unlock_update")
			Result.put ("upper_bar", "upper_bar")
			Result.put ("user_can_resize", "user_can_resize")
			Result.put ("accelerators", "accelerators")
			Result.put ("create_implementation", "create_implementation")
			Result.put ("icon_name", "icon_name")
			Result.put ("icon_pixmap", "icon_pixmap")
			Result.put ("initialize", "initialize")
			Result.put ("is_maximized", "is_maximized")
			Result.put ("is_minimized", "is_minimized")
			Result.put ("lower", "lower")
			Result.put ("maximize", "maximize")
			Result.put ("minimize", "minimize")
			Result.put ("raise", "raise")
			Result.put ("remove_icon_name", "remove_icon_name")
			Result.put ("restore", "restore")
			Result.put ("set_icon_name", "set_icon_name")
			Result.put ("set_icon_pixmap", "set_icon_pixmap")
			Result.put ("object_comparison", "object_comparison")
			Result.put ("data", "data")
			Result.put ("default_create_called", "default_create_called")
			Result.put ("is_initialized", "is_initialized")
			Result.put ("pixmap_path", "pixmap_path")
			Result.put ("internal_id", "internal_id")
			Result.put ("target_name", "target_name")
			Result.put ("minimum_height_set_by_user", "minimum_height_set_by_user")
			Result.put ("implementation", "implementation")
			Result.put ("c_memory", "c_memory")
			Result.put ("eiffel_memory", "eiffel_memory")
			Result.put ("full_collector", "full_collector")
			Result.put ("incremental_collector", "incremental_collector")
			Result.put ("total_memory", "total_memory")
			Result.put ("changeable_comparison_criterion", "changeable_comparison_criterion")
			Result.put ("maximum_dimension", "maximum_dimension")
			Result.put ("default_cancel_button", "default_cancel_button")
			Result.put ("default_push_button", "default_push_button")
			Result.put ("is_modal", "is_modal")
			Result.put ("is_relative", "is_relative")
			Result.put ("set_default_push_button", "set_default_push_button")
			Result.put ("set_default_cancel_button", "set_default_cancel_button")
			Result.put ("remove_default_cancel_button", "remove_default_cancel_button")
			Result.put ("remove_default_push_button", "remove_default_push_button")
			Result.put ("enable_maximize", "enable_maximize")
			Result.put ("disable_maximize", "disable_maximize")
			Result.put ("show_modal_to_window", "show_modal_to_window")
			Result.put ("show_relative_to_window", "show_relative_to_window")
			Result.put ("dialog_key_press_action", "dialog_key_press_action")
			
				-- Add names specific to Build.
			Result.put ("window", "window")
			Result.put ("make_with_window", "make_with_window")
				-- Set object comparison.
			Result.compare_objects
		end

end -- class BUILD_RESERVED_WORDS
