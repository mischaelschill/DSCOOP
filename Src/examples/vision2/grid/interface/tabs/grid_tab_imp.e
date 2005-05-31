indexing
	description: "Objects that represent an EV_TITLED_WINDOW.%
		%The original version of this class was generated by EiffelBuild."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	GRID_TAB_IMP

inherit
	EV_VERTICAL_BOX
		redefine
			initialize, is_in_default_state
		end
			
	CONSTANTS
		undefine
			is_equal, default_create, copy
		end

-- This class is the implementation of an EV_TITLED_WINDOW generated by EiffelBuild.
-- You should not modify this code by hand, as it will be re-generated every time
-- modifications are made to the project.

feature {NONE}-- Initialization

	initialize is
			-- Initialize `Current'.
		do
			Precursor {EV_VERTICAL_BOX}
			initialize_constants
			
				-- Create all widgets.
			create addition_frame
			create l_ev_vertical_box_1
			create l_ev_table_1
			create new_label_button
			create misc_button
			create custom_button
			create icon_view_button
			create colored_button
			create build_ball_demo_button
			create removal_frame
			create l_ev_vertical_box_2
			create l_ev_table_2
			create remove_all_rows_button
			create remove_all_columns_button
			create clear_items_button
			create display_frame
			create l_ev_vertical_box_3
			create l_ev_table_3
			create is_column_resize_immediate_button
			create is_header_displayed_button
			create l_ev_horizontal_box_1
			create is_row_height_fixed
			create fixed_row_height_spin_button
			create l_ev_horizontal_box_2
			create l_ev_label_1
			create foreground_color_combo
			create l_ev_horizontal_box_3
			create l_ev_label_2
			create background_color_combo
			create are_row_separators_enabled_button
			create are_column_separators_enabled_button
			create l_ev_horizontal_box_4
			create l_ev_label_3
			create separator_color_combo
			create divider_frame
			create l_ev_vertical_box_4
			create is_vertical_divider_displayed_button
			create l_ev_horizontal_box_5
			create is_vertical_divider_dashed_button
			create is_vertical_divider_solid_button
			create scrolling_frame
			create l_ev_vertical_box_5
			create is_horizontal_scrolling_per_item
			create is_vertical_scrolling_per_item
			create l_ev_notebook_1
			create l_ev_vertical_box_6
			create l_ev_horizontal_box_6
			create is_partially_dynamic
			create is_completely_dynamic
			create resize_rows_columns_box
			create resize_columns_to_button
			create resize_columns_to_entry
			create resize_rows_to_button
			create resize_rows_to_entry
			create l_ev_vertical_box_7
			create is_tree_enabled_button
			create tree_lines_enabled
			create l_ev_horizontal_box_7
			create l_ev_label_4
			create subrow_indent_button
			create l_ev_horizontal_box_8
			create l_ev_label_5
			create subnode_pixmaps_combo
			create set_selected_row_as_subnode_button
			create l_ev_horizontal_box_9
			create expand_all_button
			create collapse_all_button
			create draw_tree_check_button
			create l_ev_vertical_box_8
			create l_ev_frame_1
			create l_ev_horizontal_box_10
			create l_ev_vertical_box_9
			create set_background_of_selection_button
			create set_tree_node_connector_button
			create set_background_color_combo
			create l_ev_frame_2
			create l_ev_vertical_box_10
			create columns_drawn_above_rows_button
			create l_ev_vertical_box_11
			create enable_pick_and_drop_button
			
				-- Build_widget_structure.
			extend (addition_frame)
			addition_frame.extend (l_ev_vertical_box_1)
			l_ev_vertical_box_1.extend (l_ev_table_1)
			extend (removal_frame)
			removal_frame.extend (l_ev_vertical_box_2)
			l_ev_vertical_box_2.extend (l_ev_table_2)
			extend (display_frame)
			display_frame.extend (l_ev_vertical_box_3)
			l_ev_vertical_box_3.extend (l_ev_table_3)
			l_ev_horizontal_box_1.extend (is_row_height_fixed)
			l_ev_horizontal_box_1.extend (fixed_row_height_spin_button)
			l_ev_horizontal_box_2.extend (l_ev_label_1)
			l_ev_horizontal_box_2.extend (foreground_color_combo)
			l_ev_horizontal_box_3.extend (l_ev_label_2)
			l_ev_horizontal_box_3.extend (background_color_combo)
			l_ev_horizontal_box_4.extend (l_ev_label_3)
			l_ev_horizontal_box_4.extend (separator_color_combo)
			extend (divider_frame)
			divider_frame.extend (l_ev_vertical_box_4)
			l_ev_vertical_box_4.extend (is_vertical_divider_displayed_button)
			l_ev_vertical_box_4.extend (l_ev_horizontal_box_5)
			l_ev_horizontal_box_5.extend (is_vertical_divider_dashed_button)
			l_ev_horizontal_box_5.extend (is_vertical_divider_solid_button)
			extend (scrolling_frame)
			scrolling_frame.extend (l_ev_vertical_box_5)
			l_ev_vertical_box_5.extend (is_horizontal_scrolling_per_item)
			l_ev_vertical_box_5.extend (is_vertical_scrolling_per_item)
			extend (l_ev_notebook_1)
			l_ev_notebook_1.extend (l_ev_vertical_box_6)
			l_ev_vertical_box_6.extend (l_ev_horizontal_box_6)
			l_ev_horizontal_box_6.extend (is_partially_dynamic)
			l_ev_horizontal_box_6.extend (is_completely_dynamic)
			l_ev_vertical_box_6.extend (resize_rows_columns_box)
			resize_rows_columns_box.extend (resize_columns_to_button)
			resize_rows_columns_box.extend (resize_columns_to_entry)
			resize_rows_columns_box.extend (resize_rows_to_button)
			resize_rows_columns_box.extend (resize_rows_to_entry)
			l_ev_notebook_1.extend (l_ev_vertical_box_7)
			l_ev_vertical_box_7.extend (is_tree_enabled_button)
			l_ev_vertical_box_7.extend (tree_lines_enabled)
			l_ev_vertical_box_7.extend (l_ev_horizontal_box_7)
			l_ev_horizontal_box_7.extend (l_ev_label_4)
			l_ev_horizontal_box_7.extend (subrow_indent_button)
			l_ev_vertical_box_7.extend (l_ev_horizontal_box_8)
			l_ev_horizontal_box_8.extend (l_ev_label_5)
			l_ev_horizontal_box_8.extend (subnode_pixmaps_combo)
			l_ev_vertical_box_7.extend (set_selected_row_as_subnode_button)
			l_ev_vertical_box_7.extend (l_ev_horizontal_box_9)
			l_ev_horizontal_box_9.extend (expand_all_button)
			l_ev_horizontal_box_9.extend (collapse_all_button)
			l_ev_vertical_box_7.extend (draw_tree_check_button)
			l_ev_notebook_1.extend (l_ev_vertical_box_8)
			l_ev_vertical_box_8.extend (l_ev_frame_1)
			l_ev_frame_1.extend (l_ev_horizontal_box_10)
			l_ev_horizontal_box_10.extend (l_ev_vertical_box_9)
			l_ev_vertical_box_9.extend (set_background_of_selection_button)
			l_ev_vertical_box_9.extend (set_tree_node_connector_button)
			l_ev_horizontal_box_10.extend (set_background_color_combo)
			l_ev_vertical_box_8.extend (l_ev_frame_2)
			l_ev_frame_2.extend (l_ev_vertical_box_10)
			l_ev_vertical_box_10.extend (columns_drawn_above_rows_button)
			l_ev_notebook_1.extend (l_ev_vertical_box_11)
			l_ev_vertical_box_11.extend (enable_pick_and_drop_button)
			
			addition_frame.set_text ("Addition")
			l_ev_table_1.resize (2, 3)
			l_ev_table_1.set_row_spacing (box_padding)
			l_ev_table_1.set_column_spacing (box_padding)
			l_ev_table_1.set_border_width (box_padding)
				-- Insert and position all children of `l_ev_table_1'.
			l_ev_table_1.put_at_position (new_label_button, 1, 1, 1, 1)
			l_ev_table_1.put_at_position (misc_button, 2, 1, 1, 1)
			l_ev_table_1.put_at_position (custom_button, 1, 2, 1, 1)
			l_ev_table_1.put_at_position (icon_view_button, 2, 2, 1, 1)
			l_ev_table_1.put_at_position (colored_button, 1, 3, 1, 1)
			l_ev_table_1.put_at_position (build_ball_demo_button, 2, 3, 1, 1)
			new_label_button.set_text ("Add New Items")
			misc_button.set_text ("Build Default Item Structure")
			custom_button.set_text ("Custom Function")
			icon_view_button.set_text ("Build Icon View Structure")
			colored_button.set_text ("Build Colored Structure")
			build_ball_demo_button.set_text ("Build Ball Demo")
			removal_frame.set_text ("Removal")
			l_ev_vertical_box_2.set_border_width (box_padding)
			l_ev_table_2.resize (2, 2)
			l_ev_table_2.set_row_spacing (box_padding)
			l_ev_table_2.set_column_spacing (box_padding)
				-- Insert and position all children of `l_ev_table_2'.
			l_ev_table_2.put_at_position (remove_all_rows_button, 1, 1, 1, 1)
			l_ev_table_2.put_at_position (remove_all_columns_button, 2, 1, 1, 1)
			l_ev_table_2.put_at_position (clear_items_button, 1, 2, 1, 1)
			remove_all_rows_button.set_text ("Remove All Rows")
			remove_all_columns_button.set_text ("Remove All Columns")
			clear_items_button.set_text ("Clear Grid")
			display_frame.set_text ("Display Properties")
			l_ev_vertical_box_3.disable_item_expand (l_ev_table_3)
			l_ev_table_3.resize (2, 4)
			l_ev_table_3.set_row_spacing (box_padding)
			l_ev_table_3.set_column_spacing (box_padding)
				-- Insert and position all children of `l_ev_table_3'.
			l_ev_table_3.put_at_position (is_column_resize_immediate_button, 1, 1, 1, 1)
			l_ev_table_3.put_at_position (is_header_displayed_button, 2, 1, 1, 1)
			l_ev_table_3.put_at_position (l_ev_horizontal_box_1, 1, 2, 1, 1)
			l_ev_table_3.put_at_position (l_ev_horizontal_box_2, 2, 4, 1, 1)
			l_ev_table_3.put_at_position (l_ev_horizontal_box_3, 1, 4, 1, 1)
			l_ev_table_3.put_at_position (are_row_separators_enabled_button, 2, 3, 1, 1)
			l_ev_table_3.put_at_position (are_column_separators_enabled_button, 1, 3, 1, 1)
			l_ev_table_3.put_at_position (l_ev_horizontal_box_4, 2, 2, 1, 1)
			is_column_resize_immediate_button.enable_select
			is_column_resize_immediate_button.set_text ("Is Column Resize Immediate")
			is_header_displayed_button.enable_select
			is_header_displayed_button.set_text ("Is Header Displayed")
			l_ev_horizontal_box_1.disable_item_expand (is_row_height_fixed)
			l_ev_horizontal_box_1.disable_item_expand (fixed_row_height_spin_button)
			is_row_height_fixed.enable_select
			is_row_height_fixed.set_text ("Is Row Height Fixed")
			fixed_row_height_spin_button.set_text ("16")
			fixed_row_height_spin_button.value_range.adapt (create {INTEGER_INTERVAL}.make (1, 1000))
			fixed_row_height_spin_button.set_value (16)
			l_ev_horizontal_box_2.disable_item_expand (l_ev_label_1)
			l_ev_label_1.set_text ("Foreground Color : ")
			l_ev_horizontal_box_3.disable_item_expand (l_ev_label_2)
			l_ev_label_2.set_text ("Background Color : ")
			are_row_separators_enabled_button.set_text ("Are Row Separators Enabled")
			are_column_separators_enabled_button.set_text ("Are Column Separators Enabled")
			l_ev_horizontal_box_4.disable_item_expand (l_ev_label_3)
			l_ev_label_3.set_text ("Separator Color : ")
			divider_frame.set_text ("Divider Properties")
			l_ev_vertical_box_4.set_padding_width (box_padding)
			l_ev_vertical_box_4.set_border_width (box_padding)
			l_ev_vertical_box_4.disable_item_expand (is_vertical_divider_displayed_button)
			is_vertical_divider_displayed_button.set_text ("Is Vertical Divider Displayed")
			l_ev_horizontal_box_5.disable_item_expand (is_vertical_divider_dashed_button)
			l_ev_horizontal_box_5.disable_item_expand (is_vertical_divider_solid_button)
			is_vertical_divider_dashed_button.disable_sensitive
			is_vertical_divider_dashed_button.set_text ("Is Vertical Divider Dashed")
			is_vertical_divider_solid_button.disable_sensitive
			is_vertical_divider_solid_button.set_text ("Is Vertical Divider Solid")
			scrolling_frame.set_text ("Scrolling Properties")
			l_ev_vertical_box_5.set_padding_width (box_padding)
			l_ev_vertical_box_5.set_border_width (box_padding)
			l_ev_vertical_box_5.disable_item_expand (is_horizontal_scrolling_per_item)
			l_ev_vertical_box_5.disable_item_expand (is_vertical_scrolling_per_item)
			is_horizontal_scrolling_per_item.set_text ("Is Horizontal Scolling Per Item")
			is_vertical_scrolling_per_item.enable_select
			is_vertical_scrolling_per_item.set_text ("Is Vertical Scrolling Per Item")
			l_ev_notebook_1.set_item_text (l_ev_vertical_box_6, "Dynamic")
			l_ev_notebook_1.set_item_text (l_ev_vertical_box_7, "Tree")
			l_ev_notebook_1.set_item_text (l_ev_vertical_box_8, "Misc")
			l_ev_notebook_1.set_item_text (l_ev_vertical_box_11, "P'n'D")
			l_ev_vertical_box_6.set_padding_width (box_padding)
			l_ev_vertical_box_6.set_border_width (box_padding)
			l_ev_vertical_box_6.disable_item_expand (l_ev_horizontal_box_6)
			l_ev_vertical_box_6.disable_item_expand (resize_rows_columns_box)
			l_ev_horizontal_box_6.disable_item_expand (is_partially_dynamic)
			l_ev_horizontal_box_6.disable_item_expand (is_completely_dynamic)
			is_partially_dynamic.set_text ("Is Partially Dynamic")
			is_completely_dynamic.set_text ("Is Completely Dynamic")
			resize_rows_columns_box.disable_sensitive
			resize_rows_columns_box.set_padding_width (box_padding)
			resize_rows_columns_box.disable_item_expand (resize_columns_to_button)
			resize_rows_columns_box.disable_item_expand (resize_columns_to_entry)
			resize_rows_columns_box.disable_item_expand (resize_rows_to_button)
			resize_rows_columns_box.disable_item_expand (resize_rows_to_entry)
			resize_columns_to_button.set_text ("Resize Columns To")
			resize_columns_to_entry.disable_sensitive
			resize_columns_to_entry.set_text ("1")
			resize_columns_to_entry.value_range.adapt (create {INTEGER_INTERVAL}.make (1, 1000000))
			resize_columns_to_entry.set_value (1)
			resize_rows_to_button.set_text ("Resize Rows To")
			resize_rows_to_entry.disable_sensitive
			resize_rows_to_entry.set_text ("1")
			resize_rows_to_entry.value_range.adapt (create {INTEGER_INTERVAL}.make (1, 1000000))
			resize_rows_to_entry.set_value (1)
			l_ev_vertical_box_7.set_padding_width (box_padding)
			l_ev_vertical_box_7.set_border_width (box_padding)
			l_ev_vertical_box_7.disable_item_expand (is_tree_enabled_button)
			l_ev_vertical_box_7.disable_item_expand (tree_lines_enabled)
			l_ev_vertical_box_7.disable_item_expand (l_ev_horizontal_box_7)
			l_ev_vertical_box_7.disable_item_expand (l_ev_horizontal_box_8)
			l_ev_vertical_box_7.disable_item_expand (set_selected_row_as_subnode_button)
			l_ev_vertical_box_7.disable_item_expand (l_ev_horizontal_box_9)
			l_ev_vertical_box_7.disable_item_expand (draw_tree_check_button)
			is_tree_enabled_button.set_text ("Is Tree Enabled")
			tree_lines_enabled.enable_select
			tree_lines_enabled.set_text ("Tree Lines Enabled")
			l_ev_horizontal_box_7.disable_item_expand (l_ev_label_4)
			l_ev_label_4.set_text ("Subrow_indent : ")
			l_ev_label_4.align_text_left
			subrow_indent_button.value_range.adapt (create {INTEGER_INTERVAL}.make (0, 200))
			l_ev_horizontal_box_8.disable_item_expand (l_ev_label_5)
			l_ev_label_5.set_text ("Subnode pixmaps : ")
			l_ev_label_5.align_text_left
			set_selected_row_as_subnode_button.set_text ("Set selected row as subnode")
			l_ev_horizontal_box_9.set_padding_width (box_padding)
			expand_all_button.set_text ("Expand all")
			collapse_all_button.set_text ("Collapse all")
			draw_tree_check_button.set_text ("Draw New Tree Nodes")
			l_ev_vertical_box_8.disable_item_expand (l_ev_frame_1)
			l_ev_vertical_box_8.disable_item_expand (l_ev_frame_2)
			l_ev_frame_1.set_text ("Colors")
			l_ev_vertical_box_9.disable_item_expand (set_background_of_selection_button)
			set_background_of_selection_button.set_text ("Set Background of Selection To")
			set_tree_node_connector_button.set_text ("Set Tree Node Connectors To")
			l_ev_frame_2.set_text ("Column Drawing")
			columns_drawn_above_rows_button.enable_select
			columns_drawn_above_rows_button.set_text ("Columns Drawn Above Rows")
			l_ev_vertical_box_11.disable_item_expand (enable_pick_and_drop_button)
			enable_pick_and_drop_button.set_text ("Enable pick and drop on all items")
			set_padding_width (box_padding)
			set_border_width (box_padding)
			disable_item_expand (addition_frame)
			disable_item_expand (removal_frame)
			disable_item_expand (display_frame)
			disable_item_expand (divider_frame)
			disable_item_expand (scrolling_frame)
			disable_item_expand (l_ev_notebook_1)
			
				--Connect events.
			new_label_button.select_actions.extend (agent new_label_button_selected)
			misc_button.select_actions.extend (agent misc_button_selected)
			custom_button.select_actions.extend (agent custom_button_selected)
			icon_view_button.select_actions.extend (agent icon_view_button_selected)
			colored_button.select_actions.extend (agent colored_button_selected)
			build_ball_demo_button.select_actions.extend (agent build_ball_demo_button_selected)
			remove_all_rows_button.select_actions.extend (agent remove_all_row_button_selected)
			remove_all_columns_button.select_actions.extend (agent remove_all_columns_button_selected)
			clear_items_button.select_actions.extend (agent clear_items_button_selected)
			is_column_resize_immediate_button.select_actions.extend (agent is_column_resize_immediate_button_selected)
			is_header_displayed_button.select_actions.extend (agent is_header_displayed_button_selected)
			is_row_height_fixed.select_actions.extend (agent is_row_height_fixed_selected)
			fixed_row_height_spin_button.change_actions.extend (agent fixed_row_height_spin_button_changed (?))
			foreground_color_combo.select_actions.extend (agent foreground_color_combo_selected)
			background_color_combo.select_actions.extend (agent background_color_combo_selected)
			are_row_separators_enabled_button.select_actions.extend (agent are_row_separators_enabled_button_selected)
			are_column_separators_enabled_button.select_actions.extend (agent are_column_separators_enabled_button_selected)
			separator_color_combo.select_actions.extend (agent separator_color_combo_selected)
			is_vertical_divider_displayed_button.select_actions.extend (agent is_vertical_divider_displayed_button_selected)
			is_vertical_divider_dashed_button.select_actions.extend (agent is_vertical_divider_dashed_button_selected)
			is_vertical_divider_solid_button.select_actions.extend (agent is_vertical_divider_solid_button_selected)
			is_horizontal_scrolling_per_item.select_actions.extend (agent is_horizontal_scrolling_per_item_selected)
			is_vertical_scrolling_per_item.select_actions.extend (agent is_vertical_scrolling_per_item_selected)
			is_partially_dynamic.select_actions.extend (agent is_partially_dynamic_selected)
			is_completely_dynamic.select_actions.extend (agent is_completely_dynamic_selected)
			resize_columns_to_button.select_actions.extend (agent resize_columns_to_button_selected)
			resize_columns_to_entry.change_actions.extend (agent resize_columns_to_entry_selected (?))
			resize_rows_to_button.select_actions.extend (agent resize_row_to_button_selected)
			resize_rows_to_entry.change_actions.extend (agent resize_rows_to_entry_changed (?))
			is_tree_enabled_button.select_actions.extend (agent is_tree_enabled_button_selected)
			tree_lines_enabled.select_actions.extend (agent tree_lines_enabled_selected)
			subrow_indent_button.change_actions.extend (agent subrow_indent_button_changed (?))
			subnode_pixmaps_combo.select_actions.extend (agent subnode_pixmaps_combo_selected)
			set_selected_row_as_subnode_button.select_actions.extend (agent set_selected_row_as_subnode_button_selected)
			expand_all_button.select_actions.extend (agent expand_all_button_selected)
			collapse_all_button.select_actions.extend (agent collapse_all_button_selected)
			draw_tree_check_button.select_actions.extend (agent draw_tree_check_button_selected)
			set_background_color_combo.select_actions.extend (agent set_background_color_combo_selected)
			columns_drawn_above_rows_button.select_actions.extend (agent columns_drawn_above_rows_button_selected)
			enable_pick_and_drop_button.select_actions.extend (agent enable_pick_and_drop_button_selected)
				-- Close the application when an interface close
				-- request is recieved on `Current'. i.e. the cross is clicked.

				-- Call `user_initialization'.
			user_initialization
		end

feature -- Access

	foreground_color_combo, background_color_combo, separator_color_combo, subnode_pixmaps_combo,
	set_background_color_combo: EV_COMBO_BOX
	fixed_row_height_spin_button, resize_columns_to_entry,
	resize_rows_to_entry, subrow_indent_button: EV_SPIN_BUTTON
	new_label_button, misc_button, custom_button,
	icon_view_button, colored_button, build_ball_demo_button, remove_all_rows_button,
	remove_all_columns_button, clear_items_button, set_selected_row_as_subnode_button,
	expand_all_button, collapse_all_button: EV_BUTTON
	is_vertical_divider_dashed_button, is_vertical_divider_solid_button,
	set_background_of_selection_button, set_tree_node_connector_button: EV_RADIO_BUTTON
	resize_rows_columns_box: EV_HORIZONTAL_BOX
	is_column_resize_immediate_button,
	is_header_displayed_button, is_row_height_fixed, are_row_separators_enabled_button,
	are_column_separators_enabled_button, is_vertical_divider_displayed_button, is_horizontal_scrolling_per_item,
	is_vertical_scrolling_per_item, is_partially_dynamic, is_completely_dynamic, resize_columns_to_button,
	resize_rows_to_button, is_tree_enabled_button, tree_lines_enabled, draw_tree_check_button,
	columns_drawn_above_rows_button, enable_pick_and_drop_button: EV_CHECK_BUTTON
	addition_frame, removal_frame,
	display_frame, divider_frame, scrolling_frame: EV_FRAME

feature {NONE} -- Implementation

	l_ev_table_1, l_ev_table_2, l_ev_table_3: EV_TABLE
	l_ev_notebook_1: EV_NOTEBOOK
	l_ev_horizontal_box_1,
	l_ev_horizontal_box_2, l_ev_horizontal_box_3, l_ev_horizontal_box_4, l_ev_horizontal_box_5,
	l_ev_horizontal_box_6, l_ev_horizontal_box_7, l_ev_horizontal_box_8, l_ev_horizontal_box_9,
	l_ev_horizontal_box_10: EV_HORIZONTAL_BOX
	l_ev_vertical_box_1, l_ev_vertical_box_2, l_ev_vertical_box_3,
	l_ev_vertical_box_4, l_ev_vertical_box_5, l_ev_vertical_box_6, l_ev_vertical_box_7,
	l_ev_vertical_box_8, l_ev_vertical_box_9, l_ev_vertical_box_10, l_ev_vertical_box_11: EV_VERTICAL_BOX
	l_ev_label_1,
	l_ev_label_2, l_ev_label_3, l_ev_label_4, l_ev_label_5: EV_LABEL
	l_ev_frame_1, l_ev_frame_2: EV_FRAME

feature {NONE} -- Implementation

	is_in_default_state: BOOLEAN is
			-- Is `Current' in its default state?
		do
			-- Re-implement if you wish to enable checking
			-- for `Current'.
			Result := True
		end
	
	user_initialization is
			-- Feature for custom initialization, called at end of `initialize'.
		deferred
		end
	
	new_label_button_selected is
			-- Called by `select_actions' of `new_label_button'.
		deferred
		end
	
	misc_button_selected is
			-- Called by `select_actions' of `misc_button'.
		deferred
		end
	
	custom_button_selected is
			-- Called by `select_actions' of `custom_button'.
		deferred
		end
	
	icon_view_button_selected is
			-- Called by `select_actions' of `icon_view_button'.
		deferred
		end
	
	colored_button_selected is
			-- Called by `select_actions' of `colored_button'.
		deferred
		end
	
	build_ball_demo_button_selected is
			-- Called by `select_actions' of `build_ball_demo_button'.
		deferred
		end
	
	remove_all_row_button_selected is
			-- Called by `select_actions' of `remove_all_rows_button'.
		deferred
		end
	
	remove_all_columns_button_selected is
			-- Called by `select_actions' of `remove_all_columns_button'.
		deferred
		end
	
	clear_items_button_selected is
			-- Called by `select_actions' of `clear_items_button'.
		deferred
		end
	
	is_column_resize_immediate_button_selected is
			-- Called by `select_actions' of `is_column_resize_immediate_button'.
		deferred
		end
	
	is_header_displayed_button_selected is
			-- Called by `select_actions' of `is_header_displayed_button'.
		deferred
		end
	
	is_row_height_fixed_selected is
			-- Called by `select_actions' of `is_row_height_fixed'.
		deferred
		end
	
	fixed_row_height_spin_button_changed (a_value: INTEGER) is
			-- Called by `change_actions' of `fixed_row_height_spin_button'.
		deferred
		end
	
	foreground_color_combo_selected is
			-- Called by `select_actions' of `foreground_color_combo'.
		deferred
		end
	
	background_color_combo_selected is
			-- Called by `select_actions' of `background_color_combo'.
		deferred
		end
	
	are_row_separators_enabled_button_selected is
			-- Called by `select_actions' of `are_row_separators_enabled_button'.
		deferred
		end
	
	are_column_separators_enabled_button_selected is
			-- Called by `select_actions' of `are_column_separators_enabled_button'.
		deferred
		end
	
	separator_color_combo_selected is
			-- Called by `select_actions' of `separator_color_combo'.
		deferred
		end
	
	is_vertical_divider_displayed_button_selected is
			-- Called by `select_actions' of `is_vertical_divider_displayed_button'.
		deferred
		end
	
	is_vertical_divider_dashed_button_selected is
			-- Called by `select_actions' of `is_vertical_divider_dashed_button'.
		deferred
		end
	
	is_vertical_divider_solid_button_selected is
			-- Called by `select_actions' of `is_vertical_divider_solid_button'.
		deferred
		end
	
	is_horizontal_scrolling_per_item_selected is
			-- Called by `select_actions' of `is_horizontal_scrolling_per_item'.
		deferred
		end
	
	is_vertical_scrolling_per_item_selected is
			-- Called by `select_actions' of `is_vertical_scrolling_per_item'.
		deferred
		end
	
	is_partially_dynamic_selected is
			-- Called by `select_actions' of `is_partially_dynamic'.
		deferred
		end
	
	is_completely_dynamic_selected is
			-- Called by `select_actions' of `is_completely_dynamic'.
		deferred
		end
	
	resize_columns_to_button_selected is
			-- Called by `select_actions' of `resize_columns_to_button'.
		deferred
		end
	
	resize_columns_to_entry_selected (a_value: INTEGER) is
			-- Called by `change_actions' of `resize_columns_to_entry'.
		deferred
		end
	
	resize_row_to_button_selected is
			-- Called by `select_actions' of `resize_rows_to_button'.
		deferred
		end
	
	resize_rows_to_entry_changed (a_value: INTEGER) is
			-- Called by `change_actions' of `resize_rows_to_entry'.
		deferred
		end
	
	is_tree_enabled_button_selected is
			-- Called by `select_actions' of `is_tree_enabled_button'.
		deferred
		end
	
	tree_lines_enabled_selected is
			-- Called by `select_actions' of `tree_lines_enabled'.
		deferred
		end
	
	subrow_indent_button_changed (a_value: INTEGER) is
			-- Called by `change_actions' of `subrow_indent_button'.
		deferred
		end
	
	subnode_pixmaps_combo_selected is
			-- Called by `select_actions' of `subnode_pixmaps_combo'.
		deferred
		end
	
	set_selected_row_as_subnode_button_selected is
			-- Called by `select_actions' of `set_selected_row_as_subnode_button'.
		deferred
		end
	
	expand_all_button_selected is
			-- Called by `select_actions' of `expand_all_button'.
		deferred
		end
	
	collapse_all_button_selected is
			-- Called by `select_actions' of `collapse_all_button'.
		deferred
		end
	
	draw_tree_check_button_selected is
			-- Called by `select_actions' of `draw_tree_check_button'.
		deferred
		end
	
	set_background_color_combo_selected is
			-- Called by `select_actions' of `set_background_color_combo'.
		deferred
		end
	
	columns_drawn_above_rows_button_selected is
			-- Called by `select_actions' of `columns_drawn_above_rows_button'.
		deferred
		end
	
	enable_pick_and_drop_button_selected is
			-- Called by `select_actions' of `enable_pick_and_drop_button'.
		deferred
		end
	

end -- class GRID_TAB_IMP
