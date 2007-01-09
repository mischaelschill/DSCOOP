indexing
	description: "Objects that represent an EV_TITLED_WINDOW.%
		%The original version of this class was generated by EiffelBuild."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	EB_METRIC_SELECTOR

inherit
	EB_METRIC_SELECTOR_IMP

	EVS_GRID_TWO_WAY_SORTING_ORDER
		undefine
			default_create,
			is_equal,
			copy
		end

	QL_SHARED_UNIT
		undefine
			default_create,
			is_equal,
			copy
		end

	EB_METRIC_SHARED
		undefine
			default_create,
			is_equal,
			copy
		end

	EB_METRIC_INTERFACE_PROVIDER
		undefine
			default_create,
			is_equal,
			copy
		end

create
	make

feature {NONE} -- Initialization

	make (a_selectable: BOOLEAN) is
			-- Initialize current.
			-- If `a_selectable' is True, draw checkbox for selection.
		do
			is_selectable := a_selectable
			if is_selectable then
				create selection_status.make (30)
			else
				create selection_status.make (0)
			end
			create metric_name_list.make
			create metric_name_row_table.make (30)
			create input_cache.make (20)
			create unit_row_list.make
			create delayed_timeout.make (agent delayed_search_metric, 10)
			default_create
			enable_tooltip_contain_go_to_definition_message
		ensure
			is_selectable_set: is_selectable = a_selectable
			metric_name_list_attached: metric_name_list /= Void
			metric_name_row_table_attached: metric_name_row_table /= Void
			input_cache_attached: input_cache /= Void
			unit_row_list_attached: unit_row_list /= Void
			delayed_timeout_attached: delayed_timeout /= Void
		end

	user_initialization is
			-- Called by `initialize'.
			-- Any custom user initialization that
			-- could not be performed in `initialize',
			-- (due to regeneration of implementation class)
			-- can be added here.		
		local
			l_sort_info: EVS_GRID_THREE_WAY_SORTING_INFO [ANY]
		do

			create metric_selected_actions
			create group_selected_actions
			create delete_key_pressed_actions
			create double_click_actions
				-- Initialize `metric_table'.
			create metric_table.make (13)

				-- Initialize `metric_grid'.
			create metric_grid
			if is_selectable then
				metric_grid.set_column_count_to (2)
				select_predefined_btn.set_pixmap (pixmaps.icon_pixmaps.metric_basic_readonly_icon)
				select_userdefined_btn.set_pixmap (pixmaps.icon_pixmaps.metric_basic_icon)
				select_predefined_btn.select_actions.extend (agent on_select_predefined_metric)
				select_userdefined_btn.select_actions.extend (agent on_select_userdefined_metric)
				metric_selection_toolbar.show
			else
				metric_grid.set_column_count_to (1)
				metric_selection_toolbar.hide
			end
			metric_grid.column (metric_column_index).header_item.set_text (metric_names.t_metrics)
			metric_grid.enable_default_tree_navigation_behavior (True, True, True, True)
			metric_grid.enable_selection_on_single_button_click
			create metric_grid_wrapper.make (metric_grid)
			metric_grid_area.extend (metric_grid_wrapper.component_widget)

				-- Initialize sorting information.
			create l_sort_info.make (agent metric_order_tester, ascending_order)
			l_sort_info.enable_auto_indicator
			metric_grid_wrapper.set_sort_info (metric_column_index, l_sort_info)
			metric_grid_wrapper.set_sort_action (agent sort_agent)
			metric_grid.key_press_actions.extend (agent on_key_pressed_for_metric_navigation (?, True))
			metric_grid.key_press_string_actions.extend (agent on_key_string_pressed_for_metric_navigation (?, True))

			create move_unit_up_key_shortcut.make_with_key_combination (create {EV_KEY}.make_with_code ({EV_KEY_CONSTANTS}.key_numpad_8), True, False, False)
			create move_unit_down_key_shortcut.make_with_key_combination (create {EV_KEY}.make_with_code ({EV_KEY_CONSTANTS}.key_numpad_2), True, False, False)

			metric_grid.set_item_pebble_function (agent item_pebble_function)
			metric_grid.enable_single_row_selection
			metric_grid.row_select_actions.extend (agent on_row_selected)
			metric_grid.add_key_action (agent on_move_unit (True, False), move_unit_up_key_index)
			metric_grid.add_key_action (agent on_move_unit (False, True), move_unit_down_key_index)
			metric_grid.add_key_shortcut (move_unit_up_key_index, move_unit_up_key_shortcut)
			metric_grid.add_key_shortcut (move_unit_down_key_index, move_unit_down_key_shortcut)
			metric_grid.item_drop_actions.extend (agent on_drop_unit)
			metric_grid.set_item_veto_pebble_function (agent item_veto_pebble_function)

			tree_view_checkbox.remove_text
			tree_view_checkbox.set_text (metric_names.t_group)
			tree_view_checkbox.set_pixmap (pixmaps.icon_pixmaps.metric_group_icon)
			tree_view_checkbox.enable_select
			tree_view_checkbox.select_actions.extend (agent on_tree_view_checkbox_selected)

			select_predefined_btn.set_tooltip (metric_names.f_select_predefined_metrics)
			select_userdefined_btn.set_tooltip (metric_names.f_select_userdefined_metrics)
			tree_view_checkbox.set_tooltip (metric_names.f_group_metric_by_unit)
			cached_key_field.hide
			cached_key_field.key_press_actions.extend (agent on_key_pressed_for_metric_navigation (?, False))
			cached_key_field.change_actions.extend (agent on_text_change_in_cached_key_field)
			cached_key_field.set_tooltip (metric_names.f_press_esc_to_wipe_out)

			move_unit_up_btn.set_pixmap (pixmaps.icon_pixmaps.general_move_up_icon)
			move_unit_up_btn.set_tooltip (metric_names.f_move_unit_up.as_string_32 + metric_names.f_rearrange_unit)
			move_unit_up_btn.select_actions.extend (agent on_move_unit (True, False))

			move_unit_down_btn.set_pixmap (pixmaps.icon_pixmaps.general_move_down_icon)
			move_unit_down_btn.set_tooltip (metric_names.f_move_unit_down.as_string_32 + metric_names.f_rearrange_unit)
			move_unit_down_btn.select_actions.extend (agent on_move_unit (False, True))
		ensure then
			metric_selected_actions_attached: metric_selected_actions /= Void
			group_selected_actions_attached: group_selected_actions /= Void
			delete_key_pressed_actions_attached: delete_key_pressed_actions /= Void
			metric_table_attached: metric_table /= Void
			double_click_actions_attached: double_click_actions /= Void
		end

feature -- Access

	metric_selected_actions: ACTION_SEQUENCE [TUPLE [EB_METRIC]]
			-- Actions to be performed when a metric is selected in `metric_grid'.

	group_selected_actions: ACTION_SEQUENCE [TUPLE]
			-- Actions to be performed when a group item is selected

	delete_key_pressed_actions: ACTION_SEQUENCE [TUPLE [a_metric: EB_METRIC]]
			-- Actions to be performed when delete key is pressed on selected metric `a_metric'

	double_click_actions: ACTION_SEQUENCE [TUPLE [STRING]]
			-- Actions to be performed when double click on a metric item.
			-- Argument is name of the double-clicked metric.

	next_to_last_selected_metric: STRING
			-- Name of next to last selected metric
			-- Void if there is no next to last selected metric.

	last_selected_metric: STRING
			-- Name of last selected metric
			-- Void if there is no last selected metric.

	metric_column_index: INTEGER is
			-- Column index for metric
		do
			if is_selectable then
				Result := 2
			else
				Result := 1
			end
		end

	selected_metrics: LIST [STRING] is
			-- Names of selected metrics
		local
			l_tbl: like selection_status
		do
			if is_selectable then
				l_tbl := selection_status
				create {LINKED_LIST [STRING]} Result.make
				from
					l_tbl.start
				until
					l_tbl.after
				loop
					if l_tbl.item_for_iteration then
						Result.extend (l_tbl.key_for_iteration)
					end
					l_tbl.forth
				end
			else
				create {LINKED_LIST[STRING]} Result.make
			end
		end

	selected_item_name: STRING is
			-- Name of selected metric in `metric_grid'.
			-- Void if no metric is selected
		local
			l_metric: EB_METRIC
		do
			l_metric := selected_metric
			if l_metric /= Void then
				Result := l_metric.name.twin
			end
		end

	selected_metric: EB_METRIC is
			-- Selected metric
			-- Void if no metric is selected.
		local
			l_item: EV_GRID_ITEM
		do
			if metric_grid.selected_items.count > 0 then
				l_item := metric_grid.selected_items.first
				Result ?= l_item.data
			end
		end

	metric_name_list: LINKED_LIST [STRING]
			-- List of metric names in current

	metric_name_row_table: HASH_TABLE [INTEGER, STRING]
			-- Table of metric rows.
			-- Key is name of metric, value is the grid row index.

	input_cache: STRING
			-- Input cache

feature -- Status report

	is_selectable: BOOLEAN
			-- Is metric selectable

	should_invalid_metric_be_selected: BOOLEAN
			-- Should invalid metric be selected?

	should_tooltip_contain_go_to_definition_message: BOOLEAN
			-- Should tooltip of metric contain "go to definition" message?
			-- Default: True

	is_key_from_metric_grid: BOOLEAN;
			-- Is key stroke from `metrc_grid'?
			-- False indicates that key stroke is from `cached_key_field'.

feature{NONE} -- Actions

	on_tree_view_checkbox_selected is
			-- Action to be performed when `tree_view_checkbox' selection changes.
		do
			metric_selected_actions.block
			group_selected_actions.block
			metric_grid_wrapper.disable_auto_sort_order_change
			metric_grid_wrapper.sort (0, 0, 1, 0, 0, 0, 0, 0, metric_column_index)
			metric_grid_wrapper.enable_auto_sort_order_change
			try_to_selected_last_metric
			metric_selected_actions.resume
			group_selected_actions.resume
		end

	on_selection_change (a_item: EV_GRID_CHECKABLE_LABEL_ITEM) is
			-- Action to be performed when selection in `a_item' changes
		local
			l_metric: EB_METRIC
		do
			l_metric ?= a_item.data
			check l_metric /= Void end
			selection_status.force (a_item.is_checked, l_metric.name.as_lower)
		end

	on_row_selected (a_row: EV_GRID_ROW) is
			-- Action to be performed when `a_row' is selected
		local
			l_metric: EB_METRIC
			l_item: EV_GRID_ITEM
		do
			l_metric ?= a_row.data
			if l_metric /= Void then
					-- A metric row is selected.
				l_item := a_row.item (metric_column_index)
				if l_item /= Void then
					l_metric ?= l_item.data
					check l_metric /= Void end
					if not metric_selected_actions.is_empty then
						set_last_selected_metric (l_metric.name.twin)
						metric_selected_actions.call ([l_metric])
					end
				end
				move_unit_up_btn.disable_sensitive
				move_unit_down_btn.disable_sensitive
			else
					-- A group row is selected.
				group_selected_actions.call ([])
				move_unit_up_btn.enable_sensitive
				move_unit_down_btn.enable_sensitive
			end
		end

	on_select_predefined_metric is
			-- Action to be performed when selection status of `select_predefined_btn' changes
		require
			selectable: is_selectable
		do
			select_metrics (True, select_predefined_btn.is_selected)
		end

	on_select_userdefined_metric is
			-- Action to be performed when selection status of `select_userdefined_btn' changes
		require
			selectable: is_selectable
		do
			select_metrics (False, select_userdefined_btn.is_selected)
		end

	on_pointer_double_pressed_on_metric_item (a_x, a_y, a_button: INTEGER; a_x_tilt, a_y_tilt, a_pressure: DOUBLE; a_screen_x, a_screen_y: INTEGER; a_item: EV_GRID_ITEM) is
			-- Action to be performed when double click on a metric item
		local
			l_metric: EB_METRIC
		do
			if a_button = 1 and then a_item /= Void then
				l_metric ?= a_item.data
				if l_metric /= Void then
					double_click_actions.call ([l_metric.name])
				end
			end
		end

	on_key_pressed_for_metric_navigation (a_key: EV_KEY; a_on_grid: BOOLEAN) is
			-- Action to be performed `a_key' is pressed on `metric_grid' if `a_on_grid' is True,
			-- otherwise on `cached_key_field'.
		require
			a_key_attached: a_key /= Void
		local
			l_code: INTEGER
			l_metric: EB_METRIC
			l_selected_rows: LIST [EV_GRID_ROW]
			l_checkbox_item: EV_GRID_CHECKABLE_LABEL_ITEM
		do
			l_code := a_key.code
			inspect
				l_code
			when {EV_KEY_CONSTANTS}.key_enter then
				if a_on_grid and then is_selectable then
					l_selected_rows := metric_grid.selected_rows
					if l_selected_rows /= Void then
						l_checkbox_item ?= l_selected_rows.first.item (1)
						if l_checkbox_item /= Void then
							l_checkbox_item.set_is_checked (not l_checkbox_item.is_checked)
						end
					end
				end
			when {EV_KEY_CONSTANTS}.key_escape then
				input_cache.wipe_out
				delayed_timeout.request_call
				if a_on_grid then
					cached_key_field.change_actions.block
					cached_key_field.set_text (input_cache)
					cached_key_field.change_actions.resume
				end
			when {EV_KEY_CONSTANTS}.key_back_space then
				if not input_cache.is_empty then
					input_cache.keep_head (input_cache.count - 1)
					delayed_timeout.request_call
					if a_on_grid then
						cached_key_field.change_actions.block
						cached_key_field.set_text (input_cache)
						if not input_cache.is_empty then
							cached_key_field.set_caret_position (input_cache.count)
						end
						cached_key_field.change_actions.resume
					end
				end
			when {EV_KEY_CONSTANTS}.key_delete then
				if a_on_grid then
					l_metric := selected_metric
					if l_metric /= Void and then not delete_key_pressed_actions.is_empty then
						delete_key_pressed_actions.call ([l_metric])
					end
				end
			else
			end
		end

	on_key_string_pressed_for_metric_navigation (a_key: STRING_32; a_on_grid: BOOLEAN) is
			-- Action to be performed `a_key' is pressed on `metric_grid' if `a_on_grid' is True,
			-- otherwise on `cached_key_field'.
		require
			a_key_attached: a_key /= Void
		do
			if not a_key.is_equal (once "%N") and not a_key.is_equal (once "%T") then
				if a_on_grid then
					cached_key_field.change_actions.block
				end
				input_cache.append (a_key)
				delayed_timeout.request_call
				if a_on_grid then
					cached_key_field.set_text (input_cache)
					if not input_cache.is_empty then
						cached_key_field.set_caret_position (input_cache.count)
					end
					cached_key_field.change_actions.resume
				end
			end
		end

	on_text_change_in_cached_key_field is
			-- Action to be performed when text changed on `cached_key_field'
		do
			input_cache.wipe_out
			input_cache.append (cached_key_field.text)
			delayed_timeout.request_call
		end

	on_move_unit (a_up: BOOLEAN; a_after: BOOLEAN) is
			-- Action to be performed to move a unit up if `a_up' is True, otherwise move down
		local
			l_selected_rows: LIST [EV_GRID_ROW]
			l_row: EV_GRID_ROW
			l_source_unit: QL_METRIC_UNIT
			l_dest_unit: QL_METRIC_UNIT
			l_start_index: INTEGER
			l_end_index: INTEGER
			l_grid: like metric_grid
			done: BOOLEAN
		do
			l_grid := metric_grid
			l_selected_rows := l_grid.selected_rows
			if not l_selected_rows.is_empty then
				l_row := l_selected_rows.first
				l_source_unit ?= l_row.data
				if l_source_unit /= Void then
					if a_up then
						from
							l_start_index := l_row.index - 1
							l_end_index := 1
						until
							l_start_index < l_end_index or done
						loop
							l_dest_unit ?= l_grid.row (l_start_index).data
							done := l_dest_unit /= Void
							l_start_index := l_start_index - 1
						end
					else
						from
							l_start_index := l_row.index + 1
							l_end_index := l_grid.row_count
						until
							l_start_index > l_end_index or done
						loop
							l_dest_unit ?= l_grid.row (l_start_index).data
							done := l_dest_unit /= Void
							l_start_index := l_start_index + 1
						end
					end
					if l_dest_unit /= Void then
						change_unit_order (l_source_unit, l_dest_unit, a_after)
					end
				end
			end
		end

		on_drop_unit (a_item: EV_GRID_ITEM; a_unit: QL_METRIC_UNIT) is
				-- Action to be performed when `a_unit' is dropped on `a_item'
			require
				a_item_attached: a_item /= Void
				a_unit_attached: a_unit /= Void
			local
				l_dest_unit: QL_METRIC_UNIT
			do
				l_dest_unit ?= a_item.row.data
				if l_dest_unit /= Void and then a_unit /= l_dest_unit then
					change_unit_order (a_unit, l_dest_unit, True)
				end
			end

feature -- setting

	set_last_selected_metric (a_name: like last_selected_metric) is
			-- Set `last_selected_metric' with `a_name'.
		do
			set_next_to_last_selected_metric (last_selected_metric)
			if a_name = Void then
				last_selected_metric := Void
			else
				last_selected_metric := a_name.twin
			end
		ensure
			last_selected_metric_set: (a_name /= Void implies last_selected_metric.is_equal (a_name)) and
									  (a_name = Void implies last_selected_metric = Void)
		end

	set_next_to_last_selected_metric (a_name: like next_to_last_selected_metric) is
			-- Set `next_to_last_selected_metric' with `a_name'.
		do
			if a_name = Void then
				next_to_last_selected_metric := Void
			else
				next_to_last_selected_metric := a_name.twin
			end
		ensure
			next_to_last_selected_metric_set: (a_name /= Void implies next_to_last_selected_metric.is_equal (a_name)) and
									  (a_name = Void implies next_to_last_selected_metric = Void)
		end

	remove_selection is
			-- Remove selection.
		do
			metric_grid.remove_selection
		end

	enable_invalid_metric_selection is
			-- Enable selection on invalid metric.
		do
			should_invalid_metric_be_selected := True
		ensure
			invalid_metric_selection_enabled: should_invalid_metric_be_selected
		end

	disable_invalid_metric_selection is
			-- Disable selection on invalid metric.
		do
			should_invalid_metric_be_selected := False
		ensure
			invalid_metric_selection_disabled: not should_invalid_metric_be_selected
		end

feature -- Basic operations

	select_metric (a_name: STRING) is
			-- Enable metric named `a_name' is selected in `metric_grid'.
		require
			a_name_attached: a_name /= Void
		local
			l_row: EV_GRID_ROW
			l_row_index: INTEGER
			l_row_count: INTEGER
			l_metric: EB_METRIC
			done: BOOLEAN
			l_item: EV_GRID_ITEM
		do
			from
				l_row_index := 1
				l_row_count := metric_grid.row_count
			until
				l_row_index > l_row_count or done
			loop
				l_row := metric_grid.row (l_row_index)
				l_item := l_row.item (metric_column_index)
				if l_item /= Void then
					l_metric ?= l_item.data
					if l_metric /= Void then
						if l_metric.name.is_equal (a_name) then
							metric_grid.remove_selection
							if l_row.parent_row /= Void and then l_row.parent_row.is_expandable and then not l_row.parent_row.is_expanded then
								l_row.parent_row.expand
							end
							l_row.enable_select
							if l_row.is_displayed then
								l_row.ensure_visible
							end
							done := True
						end
					end
				end
				l_row_index := l_row_index + 1
			end
		end

	select_first_metric is
			-- Select the first available metric.
		local
			l_item: EV_GRID_ITEM
			l_row_index: INTEGER
			l_row_count: INTEGER
			l_metric: EB_METRIC
			done: BOOLEAN
		do
			metric_grid.remove_selection
			from
				l_row_index := 1
				l_row_count := metric_grid.row_count
			until
				l_row_index > l_row_count or done
			loop
				l_item := metric_grid.row (l_row_index).item (metric_column_index)
				if l_item /= Void then
					l_metric ?= l_item.data
					if l_metric /= Void then
						l_item.row.enable_select
						done := True
					end
				end
				l_row_index := l_row_index + 1
			end
		end

	try_to_selected_last_metric is
			-- Try to select `last_selected_metric'.
			-- If not possible, try to select the first available metric.
		do
			if last_selected_metric /= Void then
				select_metric (last_selected_metric)
				if metric_grid.selected_rows.is_empty then
					select_first_metric
				end
			end
		end

	enable_tooltip_contain_go_to_definition_message is
			-- Make sure that tooltip of metrics contain "Go to definition" message.
		do
			should_tooltip_contain_go_to_definition_message := True
		ensure
			should_tooltip_contain_go_to_definition_message_set: should_tooltip_contain_go_to_definition_message
		end

	disable_tooltip_contain_go_to_definition_message is
			-- Make sure that tooltip of metrics do not contain "Go to definition" message.
		do
			should_tooltip_contain_go_to_definition_message := False
		ensure
			should_tooltip_contain_go_to_definition_message_set: not should_tooltip_contain_go_to_definition_message
		end

feature -- Metric management

	load_metrics (a_preserve_last_selected_metric: BOOLEAN) is
			-- Load metrics in `metric_manager' into `metric_grid'.
			-- If `a_preserve_last_selected_metric' is True, try to preserve last selected metric.
		do
			metric_name_list.wipe_out
			metric_name_row_table.wipe_out
			metric_selected_actions.block
			group_selected_actions.block
			metric_grid_wrapper.disable_auto_sort_order_change
			metric_grid_wrapper.sort (0, 0, 1, 0, 0, 0, 0, 0, metric_column_index)
			metric_grid_wrapper.enable_auto_sort_order_change
			load_metric_in_grid
			if a_preserve_last_selected_metric then
				try_to_selected_last_metric
			end
			metric_selected_actions.resume
			group_selected_actions.resume
			cached_key_field.set_text ("")
		end

	load_metric_in_grid is
			-- Load `metrics' in `metric_grid'.
		local
			l_row: EV_GRID_ROW
			l_metric_list: LIST [EB_METRIC]
			l_item: EV_GRID_LABEL_ITEM
			l_unit_list: LIST [TUPLE [unit: QL_METRIC_UNIT; pixmap: EV_PIXMAP]]
			l_unit: QL_METRIC_UNIT
			l_unit_row_list: like unit_row_list
		do
			l_unit_row_list := unit_row_list
			l_unit_row_list.wipe_out
			if metric_grid.row_count > 0 then
				metric_grid.remove_rows (1, metric_grid.row_count)
			end
			if tree_view_checkbox.is_selected then
				metric_grid.enable_tree
				from
					l_unit_list := unit_list (True)
					l_unit_list.start
				until
					l_unit_list.after
				loop
					l_unit := l_unit_list.item.unit
					l_metric_list := metric_table.item (l_unit)
					if l_metric_list /= Void and then not l_metric_list.is_empty then
						metric_grid.insert_new_row (metric_grid.row_count + 1)
						l_row := metric_grid.row (metric_grid.row_count)
						create l_item.make_with_text (unit_name_table.item (l_unit))
						l_item.set_pixmap (l_unit_list.item.pixmap)
						l_row.set_item (1, l_item)
						l_row.set_data (l_unit)
						l_unit_row_list.extend (l_row)
						l_metric_list.do_all (agent load_metric (?, l_row))
						if l_row.is_expandable then
							l_row.expand
						end
					end
					l_unit_list.forth
				end
			else
				metric_grid.disable_tree
				l_metric_list := metric_table.item (no_unit)
				from
					l_metric_list.start
				until
					l_metric_list.after
				loop
					metric_grid.insert_new_row (metric_grid.row_count + 1)
					l_row := metric_grid.row (metric_grid.row_count)
					load_metric (l_metric_list.item, l_row)
					l_metric_list.forth
				end
			end
			if metric_grid.row_count > 0 then
				metric_grid.column (1).resize_to_content
			end
		end

	load_metric (a_metric: EB_METRIC; a_row: EV_GRID_ROW) is
			-- Load `a_metric' in `a_row' of `metric_grid'.
		require
			a_metric_attached: a_metric /= Void
			a_metric_registered: a_metric.is_registered
			a_row_attached: a_row /= Void
		local
			l_grid_item: EV_GRID_LABEL_ITEM
			l_grid_row: EV_GRID_ROW
			l_font: EV_FONT
			l_tooltip: STRING_GENERAL
			l_vadility: EB_METRIC_ERROR
			l_red: EV_COLOR
			l_check_item: EV_GRID_CHECKABLE_LABEL_ITEM
		do
			metric_name_list.extend (a_metric.name)
			create l_grid_item.make_with_text (a_metric.name)
			create l_font
			l_red := (create {EV_STOCK_COLORS}).red
			l_grid_item.set_font (l_font)
			l_vadility := metric_manager.metric_validity (a_metric.name)
			if l_vadility /= Void then
				l_grid_item.set_foreground_color (l_red)
			end
			l_tooltip := metric_tooltip (a_metric, should_tooltip_contain_go_to_definition_message)
			if not l_tooltip.is_empty then
				l_grid_item.set_tooltip (l_tooltip)
			end
			l_grid_item.set_pixmap (pixmap_from_metric (a_metric))
			l_grid_item.set_data (a_metric)
			l_grid_item.pointer_double_press_actions.extend (agent on_pointer_double_pressed_on_metric_item (?, ?, ?, ?, ?, ?, ?, ?, l_grid_item))
			if metric_grid.is_tree_enabled then
				a_row.insert_subrow (a_row.subrow_count + 1)
				l_grid_row := a_row.subrow (a_row.subrow_count)
			else
				l_grid_row := a_row
			end
			l_grid_row.set_item (metric_column_index, l_grid_item)
			metric_name_row_table.force (l_grid_row.index, a_metric.name)
			l_grid_row.set_data (a_metric)
			if is_selectable then
				create l_check_item
				if selection_status.item (a_metric.name.as_lower) then
					l_check_item.set_is_checked (True)
				else
					l_check_item.set_is_checked (False)
				end
				l_check_item.checked_changed_actions.extend (agent on_selection_change)
				l_check_item.set_data (a_metric)
				l_grid_row.set_item (1, l_check_item)
			end
		end

feature{NONE} -- Implementation/Sorting

	sort_agent (a_column_list: LIST [INTEGER]; a_comparator: AGENT_LIST_COMPARATOR [ANY]) is
			-- Action to be performed when sort `a_column_list' using `a_comparator'.
		require
			a_column_list_attached: a_column_list /= Void
			not_a_column_list_is_empty:
		do
			metric_selected_actions.block
			group_selected_actions.block
			metric_table := metric_manager.ordered_metrics (mapped_sorting_order, not tree_view_checkbox.is_selected)
			setup_selection_status
			load_metric_in_grid
			try_to_selected_last_metric
			metric_selected_actions.resume
			group_selected_actions.resume
		end

	metric_order_tester (a_metric, b_metric: EB_METRIC; a_order: INTEGER): BOOLEAN is
		do
		end

	current_sort_order: INTEGER is
			-- Current sort order for metrics
		do
			Result := metric_grid_wrapper.column_sort_info.item (metric_column_index).current_order
		end

	selection_status: HASH_TABLE [BOOLEAN, STRING]
			-- Selection status table
			-- Key is metric name in lower-case, value is selection status

	setup_selection_status is
			-- Setup `selection_status' after load metrics.
		local
			l_metric_tbl: like metric_table
			l_metrics: LIST [EB_METRIC]
			l_old_tbl: like selection_status
			l_new_tbl: like selection_status
			l_name: STRING
		do
			l_metric_tbl := metric_manager.ordered_metrics (mapped_sorting_order, True)
			l_metrics := l_metric_tbl.item (no_unit)
			l_old_tbl := selection_status.twin
			l_new_tbl := selection_status
			l_new_tbl.wipe_out
			from
				l_metrics.start
			until
				l_metrics.after
			loop
				l_name := l_metrics.item.name.as_lower
				if l_old_tbl.has (l_name) then
					l_new_tbl.put (l_old_tbl.item (l_name), l_name)
				else
					l_new_tbl.put (False, l_name)
				end
				l_metrics.forth
			end
		end

feature {NONE} -- Implementation

	metric_grid: ES_GRID
			-- Grid to display metrics

	metric_grid_wrapper: EVS_SEARCHABLE_COMPONENT [ANY]
			-- Sortable grid component

	metric_table: HASH_TABLE [LIST [EB_METRIC], QL_METRIC_UNIT]
			-- Table representation of `metrics'.
			-- Key is metric unit, and value is a list of metrics with that unit.

	item_pebble_function (a_item: EV_GRID_ITEM): ANY is
			-- Pebble of `a_item'.
		local
			l_item: EV_GRID_LABEL_ITEM
			l_metric: EB_METRIC
			l_unit: QL_METRIC_UNIT
		do
			l_item ?= a_item
			if l_item /= Void then
				l_metric ?= l_item.data
				if l_metric /= Void then
					Result := l_metric
					metric_grid.set_accept_cursor (cursors.cur_metric)
					metric_grid.set_deny_cursor (cursors.cur_x_metric)
				else
					l_unit ?= l_item.row.data
					Result := l_unit
				end
			end
		end

	mapped_sorting_order: INTEGER is
			-- Mapped sorting order for `metric_grid'
		do
			if current_sort_order = ascending_order then
				Result := metric_manager.ascending_order
			elseif current_sort_order = descending_order then
				Result := metric_manager.descending_order
			elseif current_sort_order = topology_order then
				Result := metric_manager.topological_order
			end
		end

	select_metrics (a_predefined: BOOLEAN; a_select: BOOLEAN) is
			-- Selected metrics:
			-- `a_predefined' is True indicates that this selection is applied to predefined metrics, otherwise user-defined metrics.
			-- `a_select' is True indicate selecting those metrics, otherwise unselect them.
		require
			selectable: is_selectable
		local
			i, c: INTEGER
			l_row: EV_GRID_ROW
			l_grid: like metric_grid
			l_metric: EB_METRIC
			l_check_item: EV_GRID_CHECKABLE_LABEL_ITEM
		do
			from
				i := 1
				l_grid := metric_grid
				c := l_grid.row_count
			until
				i > c
			loop
				l_row := l_grid.row (i)
				l_metric ?= l_row.data
				if l_metric /= Void then
					l_check_item ?= l_row.item (1)
					check l_check_item /= Void end
					if l_metric.is_predefined = a_predefined then
						if a_select then
							if metric_manager.is_metric_valid (l_metric.name) or else should_invalid_metric_be_selected then
								l_check_item.set_is_checked (a_select)
							end
						else
							l_check_item.set_is_checked (a_select)
						end
					end
				end
				i := i + 1
			end
		end

	unit_row_list: LINKED_LIST [EV_GRID_ROW]
			-- List of metric unit rows

	metric_found_background_color: EV_COLOR is
			-- Background for `cached_key_field' when at least on metric is found using text of `cached_key_field'.
		local
			l_text: EV_TEXT_FIELD
		do
			create l_text
			Result := l_text.background_color
		ensure
			result_attached: Result /= Void
		end

	no_metric_found_background_color: EV_COLOR is
			-- Background for `cached_key_field' when no metric is found using text of `cached_key_field'.
		do
			Result := preferences.search_tool_data.none_result_keyword_field_background_color
		ensure
			result_attached: Result /= Void
		end

	select_metric_starting_with_string (a_cached_string: STRING) is
			-- Try to go to metric whose name starts with `a_cached_string'.
			-- If no satosfied metric, selection in `metric_grid' won't change.
		require
			a_cached_string_attached: a_cached_string /= Void
		local
			l_index, l_old_index: INTEGER
			l_selected_rows: LIST [EV_GRID_ROW]
			l_row: EV_GRID_ROW
			l_metric: EB_METRIC
			l_row_cnt: INTEGER
			done: BOOLEAN
			l_grid: like metric_grid
			l_name: STRING
			l_cache: STRING
			l_twice: BOOLEAN
			l_parent_row: EV_GRID_ROW
		do
			if a_cached_string.is_empty then
				if cached_key_field.is_displayed then
					cached_key_field.set_background_color (metric_found_background_color)
					if cached_key_field.has_focus then
						metric_grid.set_focus
					end
					cached_key_field.hide
				end
			else
				if not cached_key_field.is_displayed then
					cached_key_field.show
				end
					-- Find the row to start search.
				l_grid := metric_grid
				l_selected_rows := l_grid.selected_rows
				if not l_selected_rows.is_empty then
					l_row := l_selected_rows.first
					if l_row.data = Void then
						l_row := Void
					end
				else
					if not metric_name_list.is_empty then
						l_row := l_grid.row (metric_name_row_table.item (metric_name_list.first))
					end
				end
				if l_row = Void then
					if not metric_name_list.is_empty then
						l_row := l_grid.row (metric_name_row_table.item (metric_name_list.first))
					end
				end
					-- Search for the first satisfied row.
				if l_row /= Void then
					from
						l_index := l_row.index
						l_old_index := l_index
						l_row_cnt := l_grid.row_count
						l_cache := input_cache
					until
						(l_twice and then l_index = l_old_index) or done
					loop
						l_row := l_grid.row (l_index)
						if l_row.data /= Void then
							l_metric ?= l_row.data
							if l_metric /= Void then
								l_name := l_metric.name
								if l_name.count >= l_cache.count and then l_name.substring (1, l_cache.count).is_case_insensitive_equal (l_cache) then
									l_parent_row := l_row.parent_row
									if l_parent_row /= Void and then l_parent_row.is_expandable and then not l_parent_row.is_expanded then
										l_parent_row.expand
									end
									l_grid.remove_selection
									l_row.enable_select
									l_row.ensure_visible
									done := True
								end
							end
						end
						l_index := l_index + 1
						if l_index > l_row_cnt then
							l_index := 1
							l_twice := True
						end
					end
					if not done then
						cached_key_field.set_background_color (no_metric_found_background_color)
					else
						cached_key_field.set_background_color (metric_found_background_color)
					end
				end
			end
		end

	delayed_timeout: ES_DELAYED_ACTION
			-- Delayed action used to react to key press in `metric_grid' or `cached_key_field'

	delayed_search_metric is
			-- Try to go to metric whose name starts with `input_cache'.
			-- If no satosfied metric, selection in `metric_grid' won't change.
		do
			select_metric_starting_with_string (input_cache)
		end

		item_veto_pebble_function (a_item: EV_GRID_ITEM; a_pebble: ANY): BOOLEAN is
				-- Function to decide if `a_pebble' can be dropped on `a_item'
			require
				a_item_attached: a_item /= Void
				a_pebble_attached: a_pebble /= Void
			local
				l_unit: QL_METRIC_UNIT
				l_row_data: QL_METRIC_UNIT
			do
				l_unit ?= a_pebble
				if l_unit /= Void then
					l_row_data ?= a_item.row.data
					Result := l_row_data /= l_unit
				end
			end

	change_unit_order (a_source_unit: QL_METRIC_UNIT; a_dest_unit: QL_METRIC_UNIT; a_after: BOOLEAN) is
			-- Change unit order:
			-- Move `a_source_unit' after `a_dest_unit' if `a_after' is True, otherwise before.
		require
			a_source_unit_attached: a_source_unit /= Void
			a_dest_unit_attached: a_dest_unit /= Void
		local
			l_unit_list: LINKED_LIST [QL_METRIC_UNIT]
		do
			l_unit_list := preferences.metric_tool_data.unit_order

			l_unit_list.start
			l_unit_list.search (a_source_unit)
			if not l_unit_list.exhausted then
				l_unit_list.remove

				l_unit_list.start
				l_unit_list.search (a_dest_unit)
				if not l_unit_list.exhausted then
					if a_after then
						l_unit_list.put_right (a_source_unit)
					else
						l_unit_list.put_left (a_source_unit)
					end

					preferences.metric_tool_data.set_unit_order (l_unit_list)
				end
			end
		end

feature{NONE} -- Key shortcuts

	move_unit_up_key_index: INTEGER is 128
			-- Key shortcut index for moving unit up

	move_unit_down_key_index: INTEGER is 129
			-- Key shortcut index for moving unit down

	move_unit_up_key_shortcut: ES_KEY_SHORTCUT
			-- Key shortcut for moving unit up

	move_unit_down_key_shortcut: ES_KEY_SHORTCUT
			-- Key shortcut for moving unit down

invariant
	metric_selected_actions_attached: metric_selected_actions /= Void
	group_selected_actions_attached: group_selected_actions /= Void
	delete_key_pressed_actions_attached: delete_key_pressed_actions /= Void
	metric_table_attached: metric_Table /= Void
	selection_status_attached: selection_status /= Void
	double_click_actions_attached: double_click_actions /= Void
	metric_name_list_attached: metric_name_list /= Void
	metric_name_row_table_attached: metric_name_row_table /= Void
	input_cache_attached: input_cache /= Void
	unit_row_list_attached: unit_row_list /= Void
	delayed_timeout_attached: delayed_timeout /= Void

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


end -- class EB_METRIC_SELECTOR

