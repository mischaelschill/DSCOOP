indexing
	description: "Objects that represent an EV_TITLED_WINDOW.%
		%The original version of this class was generated by EiffelBuild."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	EB_METRIC_CALCULATION_RESULT_AREA

inherit
	EB_METRIC_CALCULATION_RESULT_AREA_IMP

	EB_METRIC_INTERFACE_PROVIDER
		undefine
			is_equal,
			copy,
			default_create
		end

	EB_CONSTANTS
		undefine
			is_equal,
			copy,
			default_create
		end

	EB_METRIC_INTERFACE_PROVIDER
		undefine
			is_equal,
			copy,
			default_create
		end

	EVS_GRID_TWO_WAY_SORTING_ORDER
		undefine
			is_equal,
			copy,
			default_create
		end

	EB_SHARED_WRITER
		undefine
			is_equal,
			copy,
			default_create
		end

	QL_SHARED_NAMES
		undefine
			is_equal,
			copy,
			default_create
		end

	EB_SHARED_WRITER
		undefine
			is_equal,
			copy,
			default_create
		end

	EB_SHARED_PREFERENCES
		undefine
			is_equal,
			copy,
			default_create
		end

	EB_RECYCLABLE
		undefine
			is_equal,
			copy,
			default_create
		end

	SHARED_EDITOR_DATA
		undefine
			is_equal,
			copy,
			default_create
		end

	EB_METRIC_TOOL_INTERFACE
		undefine
			is_equal,
			copy,
			default_create
		end

create
	make

feature {NONE} -- Initialization

	make (a_tool: like metric_tool; a_panel: like metric_panel) is
			-- Initialize `metric_tool' with `a_tool'.
		require
			a_tool_attached: a_tool /= Void
			a_panel_attached: a_panel /= Void
		do
			set_metric_tool (a_tool)
			metric_panel := a_panel
			on_show_percentage_change_from_outside_agent := agent on_show_percentage_change_from_outside
			create content.make (2)
			content.extend (create {HASH_TABLE [EV_GRID_ITEM, INTEGER]}.make (100))
			content.extend (create {HASH_TABLE [EV_GRID_ITEM, INTEGER]}.make (100))
			create invisible_items.make
			is_first_display := True
			default_create
		ensure
			metric_tool_attached: metric_tool = a_tool
			metric_panel_attached: metric_panel /= Void
			content_attached: content /= Void
			invisible_items_attached: invisible_items /= Void
		end

	user_initialization is
			-- Called by `initialize'.
			-- Any custom user initialization that
			-- could not be performed in `initialize',
			-- (due to regeneration of implementation class)
			-- can be added here.
		local
			l_item_sort_info: EVS_GRID_TWO_WAY_SORTING_INFO [EB_METRIC_RESULT_ROW]
			l_path_sort_info: EVS_GRID_TWO_WAY_SORTING_INFO [EB_METRIC_RESULT_ROW]
			l_text: EV_TEXT_FIELD
		do
				-- Setup `input_grid'.
			create input_grid
			input_grid.hide_header
			input_grid.set_column_count_to (1)
			input_grid.set_row_count_to (1)
			input_grid.set_minimum_height (40)
			input_grid_area.extend (input_grid)

				-- Setup sortable `result_grid'.
			create result_grid
			result_grid.enable_multiple_item_selection
			result_grid.enable_selection_on_single_button_click
			result_grid.set_column_count_to (2)
			result_grid.column (2).set_title (displayed_name (metric_names.t_path))
			result_grid.set_row_count_to (100)
			result_grid.enable_partial_dynamic_content
			result_grid.set_dynamic_content_function (agent item_function)

				-- Setup `editor_token_grid_support'.
			create editor_token_grid_support.make_with_grid (result_grid)
			editor_token_grid_support.enable_editor_token_pnd
			editor_token_grid_support.color_or_font_change_actions.extend (agent on_color_or_font_changed)
			editor_token_grid_support.synchronize_color_or_font_change_with_editor
			editor_token_grid_support.synchronize_scroll_behavior_with_editor
			editor_token_grid_support.enable_ctrl_right_click_to_open_new_window

			create l_item_sort_info.make (agent item_order_tester, ascending_order)
			create l_path_sort_info.make (agent path_order_tester, ascending_order)
			l_item_sort_info.enable_auto_indicator
			l_path_sort_info.enable_auto_indicator

			create grid_wrapper.make (result_grid)
			grid_wrapper.set_sort_action (agent sort_agent)
			grid_wrapper.set_sort_info (1, l_item_sort_info)
			grid_wrapper.set_sort_info (2, l_path_sort_info)
			grid_wrapper.enable_auto_sort_order_change
			grid_wrapper.set_grid_item_function (agent grid_item_function)
			grid_wrapper.set_ensure_visible_action (agent ensure_visible_action)
			result_grid_area.extend (grid_wrapper.component_widget)
			result_lable.set_text (metric_names.t_result)
			input_lbl.set_text (metric_names.t_input_domain_title)

				-- Prepare search facilities
			create quick_search_bar.make (metric_tool.development_window)
			quick_search_bar.attach_tool (grid_wrapper)
			grid_wrapper.enable_search

				-- Setup copy & paste function.
			grid_wrapper.set_item_text_function (agent text_of_grid_item)
			grid_wrapper.set_select_all_action (agent select_all_action)
			grid_wrapper.enable_copy

				-- Delete following in docking EiffelStudio.
			result_grid.drop_actions.extend (agent metric_panel.drop_cluster)
			result_grid.drop_actions.extend (agent metric_panel.drop_class)
			result_grid.drop_actions.extend (agent metric_panel.drop_feature)
			information_bar_empty_area.drop_actions.extend (agent metric_panel.drop_cluster)
			information_bar_empty_area.drop_actions.extend (agent metric_panel.drop_class)
			information_bar_empty_area.drop_actions.extend (agent metric_panel.drop_feature)
			input_grid.drop_actions.extend (agent metric_panel.drop_cluster)
			input_grid.drop_actions.extend (agent metric_panel.drop_class)
			input_grid.drop_actions.extend (agent metric_panel.drop_feature)

			create l_text
			metric_name_text.set_background_color (l_text.background_color)
			metric_name_text.pointer_double_press_actions.extend (agent on_pointer_double_click_on_metric_name_text)
			attach_non_editable_warning_to_text (metric_names.t_text_not_editable, metric_name_text, metric_tool_window)
			attach_non_editable_warning_to_text (metric_names.t_text_not_editable, value_text, metric_tool_window)
			value_text.set_background_color (l_text.background_color)

			update_warning_area.hide
			update_warning_lbl.set_text (metric_names.t_result_not_up_to_date)
			update_warning_lbl.set_tooltip (metric_names.f_run_metric_again)
			update_warning_pixmap.copy (pixmaps.icon_pixmaps.general_warning_icon)
			update_warning_pixmap.set_tooltip (metric_names.f_run_metric_again)
			filter_invisible_item_btn.set_pixmap (pixmaps.icon_pixmaps.metric_filter_icon)
			filter_invisible_item_btn.set_tooltip (metric_names.f_filter_result)
			filter_invisible_item_btn.select_actions.extend (agent on_filter_result)
			tool_bar.hide

			show_percentage_btn.set_text ("%%")
			show_percentage_btn.set_tooltip (metric_names.f_display_in_percentage)
			show_percentage_btn.select_actions.extend (agent on_show_percentage_changes)
			preferences.metric_tool_data.display_percentage_for_ratio_preference.change_actions.extend (on_show_percentage_change_from_outside_agent)
			on_show_percentage_change_from_outside
		ensure then
			input_grid_attached: input_grid /= Void
			editor_token_grid_support_attached: editor_token_grid_support /= Void
		end

feature -- Result loading

	load_metric_result (a_metric: EB_METRIC; a_input: EB_METRIC_DOMAIN; a_value: DOUBLE; a_result: QL_DOMAIN) is
			-- Load metric result `a_result' from `a_metric' calculated over domain `a_input' into `input_grid'.
			-- `a_result' is Void indicates no detailed result available.
		require
			a_metric_attached: a_metric /= Void
			a_input_attached: a_input /= Void
		do
			if domain /= Void then
				domain.wipe_out
			end
			invisible_items.wipe_out
			load_metric_information (a_metric, a_value)
			load_input_information (a_input)
			load_detailed_result_information (a_result)
		end

	load_metric_information (a_metric: EB_METRIC; a_value: DOUBLE) is
			-- Load basic information of `a_metric'.
		require
			a_metric_attached: a_metric /= Void
		local
			l_tooltip: STRING
		do
			metric_name_text.set_text (a_metric.name)
			if metric_manager.has_metric (a_metric.name) then
				l_tooltip := metric_tooltip (a_metric, True)
				if not l_tooltip.is_empty then
					metric_name_text.set_tooltip (l_tooltip)
				end
			end
			type_name_text.set_text (displayed_name (name_of_metric_type (metric_type_id (a_metric))))
			type_pixmap.copy (pixmap_from_metric_type (metric_type_id (a_metric)))
			unit_name_text.set_text (displayed_name (a_metric.unit.name))
			unit_pixmap.copy (pixmap_from_unit (a_metric.unit))
			value_text.set_text (metric_value (a_value, a_metric.is_ratio and then show_percentage_btn.is_selected))
			value_text.set_data (a_value)
			if a_metric.is_ratio then
				show_percentage_btn.enable_sensitive
				if is_first_display then
					is_first_display := False
					show_percentage_btn.enable_select
				end
			else
				show_percentage_btn.disable_sensitive
			end
		end

	load_input_information (a_input: EB_METRIC_DOMAIN) is
			-- Load source domain information.
		require
			a_input_attached: a_input /= Void
		local
			l_item: EB_METRIC_DOMAIN_GRID_ITEM
		do
			create l_item.make (a_input)
			l_item.set_spacing (2)
			l_item.set_padding (5)
			l_item.set_left_border (3)
			input_grid.set_item (1, 1, l_item)
			input_grid.column (1).resize_to_content
		end

	load_detailed_result_information (a_result: QL_DOMAIN) is
			-- Load detailed result from `a_result'.
		do
			if a_result = Void then
				if result_grid.row_count > 0 then
					result_grid.remove_rows (1, result_grid.row_count)
				end
			else
				load_result (a_result)
			end
		end

	refresh_grid is
			-- Refresh grid.
		do
			content.i_th (1).wipe_out
			content.i_th (2).wipe_out
			if result_grid.row_count > 0 then
				result_grid.remove_rows (1, result_grid.row_count)
			end
			if domain /= Void then
				result_grid.set_row_count_to (domain.count)
			end
			result_grid.refresh_now
		end


feature{NONE} -- Implementation/Access

	input_grid: ES_GRID
			-- Grid to display input

	result_grid: ES_GRID
			-- Result grid

	grid_wrapper: EVS_SEARCHABLE_COMPONENT [EB_METRIC_RESULT_ROW]
			-- `result_grid' wrapper

	domain: DS_LINKED_LIST [EB_METRIC_RESULT_ROW]
			-- Domain to be displayed in Current

	metric_panel: EB_METRIC_PANEL
			-- Metric panel to which current is attached

feature{NONE} -- Implementation/Basic operation

	load_result (a_domain: QL_DOMAIN) is
			-- Load `a_domain' in Current.
			-- If `a_domain' is Void, clear current grid.
		local
			l_content: LIST [QL_ITEM]
			l_domain: like domain
		do
			grid_wrapper.wipe_out_sorted_columns
			grid_wrapper.column_sort_info.item (1).set_current_order (descending_order)
			grid_wrapper.column_sort_info.item (2).set_current_order (descending_order)
			result_grid.column (1).remove_pixmap
			result_grid.column (2).remove_pixmap
			if a_domain /= Void then
				result_grid.column (1).set_title (displayed_name (domain_type_name (a_domain)))
				create domain.make
				l_domain := domain
				from
					l_content := a_domain.content
					l_content.start
				until
					l_content.after
				loop
					l_domain.force_last (create {EB_METRIC_RESULT_ROW}.make(l_content.item))
					l_content.forth
				end
			else
				result_grid.column (1).set_title ("")
				domain := Void
			end
			result_grid.column (1).set_width (300)
			refresh_grid
		end

feature{NONE} -- Implementation/Sorting

	sort_agent (a_column_list: LIST [INTEGER]; a_comparator: AGENT_LIST_COMPARATOR [EB_METRIC_RESULT_ROW]) is
			-- Action to be performed when sort `a_column_list' using `a_comparator'.
		require
			a_column_list_attached: a_column_list /= Void
			not_a_column_list_is_empty:
		do
			last_comparator := a_comparator
			sort_domain (a_comparator)
			refresh_grid
		end

	sort_domain (a_comparator: AGENT_LIST_COMPARATOR [EB_METRIC_RESULT_ROW]) is
			-- Sort `domain' using `a_comparator'.
		require
			a_comparator_attached: a_comparator /= Void
		local
			l_sorter: DS_QUICK_SORTER [EB_METRIC_RESULT_ROW]
			l_domain: like domain
		do
			l_domain := domain
			if l_domain /= Void then
				create l_sorter.make (a_comparator)
				l_sorter.sort (l_domain)
			end
		end

	item_order_tester (a_item, b_item: EB_METRIC_RESULT_ROW; a_order: INTEGER): BOOLEAN
			-- Order tester for `a_item' and `b_item' using item name
		require
			a_item_attached: a_item /= Void
			b_item_attached: b_item /= Void
		do
			if a_order = ascending_order then
				Result := a_item.item.name < b_item.item.name
			else
				Result := a_item.item.name > b_item.item.name
			end
		end

	path_order_tester (a_item, b_item: EB_METRIC_RESULT_ROW; a_order: INTEGER): BOOLEAN
			-- Order tester for `a_item' and `b_item' using item path
		require
			a_item_attached: a_item /= Void
			b_item_attached: b_item /= Void
		do
			if a_order = ascending_order then
				Result := a_item.path < b_item.path
			else
				Result := a_item.path > b_item.path
			end
		end

feature{NONE} -- Implementation

	item_function (x, y: INTEGER): EV_GRID_ITEM is
			-- Grid item at position (`x', `y').
		require
			x_positive: x > 0 and x <= content.count
			y_positive: y > 0
		do
			if domain /= Void then
				if y <= domain.count then
					Result := content.i_th (x).item (y)
					if Result = Void then
						read_content (y)
						Result := content.i_th (x).item (y)
					end
				end
			end
		end

	row_background_color (y: INTEGER): EV_COLOR is
			-- Background color for items in row indexed by `y'
		local
			l_last_item: EB_METRIC_GRID_RESULT_ITEM
			l_current_item: EB_METRIC_GRID_RESULT_ITEM
			l_last_sorted_column: INTEGER
		do
			l_last_sorted_column := grid_wrapper.last_sorted_column
			if l_last_sorted_column = 0 then
					-- If no sort has been applied
				Result := result_grid.background_color
			else
					-- If sort has been applied.
				if y = 1 then
					Result := odd_row_background_color
				else
					check y > 1 end
					l_last_item ?= content.i_th (l_last_sorted_column).item (y - 1)
					l_current_item ?= content.i_th (l_last_sorted_column).item (y)
					if l_last_item = Void then
						Result := odd_row_background_color
					elseif l_current_item = Void then
						Result := l_last_item.background_color
						if Result = Void then
							Result := odd_row_background_color
						end
					else
						if l_last_item.image.is_equal (l_current_item.image) then
							Result := l_last_item.background_color
						else
								-- Alternate row background here.
							Result := next_row_background_color (l_last_item.background_color)
						end
					end
				end
			end
		ensure
			result_attached: Result /= Void
		end

	next_row_background_color (a_color: EV_COLOR): EV_COLOR is
			-- Alternative row background color according to `a_color'
		local
			l_odd_color: like odd_row_background_color
		do
			l_odd_color := odd_row_background_color
			if a_color = Void then
				Result := l_odd_color
			else
				if a_color.is_equal (l_odd_color) then
					Result := even_row_background_color
				else
					Result := l_odd_color
				end
			end
		ensure
			result_attached: Result /= Void
		end

	content: ARRAYED_LIST [HASH_TABLE [EV_GRID_ITEM, INTEGER]]
			-- Content of `domain'
			-- Key of the inner hash table is row index, value is the grid item.

	read_content (y: INTEGER) is
			-- Generate grid item from `domain'. `y' is the starting row.
			-- `cache_row_count' items will be generated every time.
		require
			domain_attached: domain /= Void
			y_valid: y > 0 and y <= domain.count
		local
			i, j: INTEGER
			l_content: DS_LIST [EB_METRIC_RESULT_ROW]
			l_tbl: HASH_TABLE [EV_GRID_ITEM, INTEGER]
		do
			from
				i := y
				j := (i + cache_row_count).min (domain.count)
				l_tbl := content.i_th (1)
				l_content := domain
				l_content.go_i_th (i)
			until
				i > j
			loop
				if not l_tbl.has (i) then
					generate_grid_item (i, l_content.item_for_iteration)
				end
				l_content.forth
				i := i + 1
			end
		end

	generate_grid_item (a_y: INTEGER; a_item: EB_METRIC_RESULT_ROW) is
			-- Generate grid items for row `a_y' from `a_item'.
		require
			domain_attached: domain /= Void
			a_y_valid: a_y > 0 and a_y <= domain.count
			a_item_attached: a_item /= Void
		local
			l_item: EB_METRIC_GRID_RESULT_ITEM
			l_path_item: EB_METRIC_GRID_RESULT_ITEM
			l_ql_item: QL_ITEM
			l_row_background_color: EV_COLOR
		do
			l_ql_item := a_item.item
			create l_item.make (l_ql_item, 1, a_y, False)
			create l_path_item.make (l_ql_item, 2, a_y, True)

			content.i_th (1).force (l_item, a_y)
			content.i_th (2).force (l_path_item, a_y)

			l_row_background_color := row_background_color (a_y)
			l_item.set_background_color (l_row_background_color)
			l_path_item.set_background_color (l_row_background_color)
		end

	cache_row_count: INTEGER is 50
			-- Cache row count

	domain_type_name (a_domain: QL_DOMAIN): STRING is
			-- Type name of `a_domain'
		require
			a_domain_attached: a_domain /= Void
		do
			if a_domain.is_target_domain then
				Result := query_language_names.ql_target
			elseif a_domain.is_group_domain then
				Result := query_language_names.ql_group
			elseif a_domain.is_class_domain then
				Result := query_language_names.ql_class
			elseif a_domain.is_generic_domain then
				Result := query_language_names.ql_generic
			elseif a_domain.is_feature_domain then
				Result := query_language_names.ql_feature
			elseif a_domain.is_argument_domain then
				Result := query_language_names.ql_argument
			elseif a_domain.is_local_domain then
				Result := query_language_names.ql_local
			elseif a_domain.is_assertion_domain then
				Result := query_language_names.ql_assertion
			elseif a_domain.is_line_domain then
				Result := query_language_names.ql_line
			elseif a_domain.is_quantity_domain then
				Result := query_language_names.ql_quantity
			end
		ensure
			good_result: Result /= Void and then not Result.is_empty
		end

	odd_row_background_color: EV_COLOR is
			-- Background color for odd rows
		do
			Result := preferences.class_browser_data.odd_row_background_color
		ensure
			result_attached: Result /= Void
		end

	even_row_background_color: EV_COLOR is
			-- Background color for even rows
		do
			Result := preferences.class_browser_data.even_row_background_color
		ensure
			result_attached: Result /= Void
		end

	quick_search_bar: EB_GRID_QUICK_SEARCH_TOOL
			-- Search bar used in browser

	grid_item_function (a_column, a_row: INTEGER): EV_GRID_ITEM is
			-- Grid item at position (`a_column', `a_row')
		do
			Result := result_grid.item (a_column, a_row)
			if Result = Void then
				Result := item_function (a_column, a_row)
			end
		end

	ensure_visible_action (a_item: EVS_GRID_SEARCHABLE_ITEM; a_selected: BOOLEAN) is
			-- Ensure that `a_item' is visible.
			-- If `a_selected' is True, make sure that `a_item' is in its selected status.
		local
			l_grid_item: EB_METRIC_GRID_RESULT_ITEM
			l_grid: like result_grid
		do
			l_grid_item ?= a_item.grid_item
			l_grid := result_grid

			if l_grid_item /= Void and then not l_grid_item.is_destroyed and then l_grid_item.is_parented then
			else
				l_grid_item ?= item_function (a_item.column_index, a_item.row_index)
				l_grid.set_item (a_item.column_index, a_item.row_index, l_grid_item)
			end
			if l_grid_item /= Void then
				l_grid.remove_selection
				l_grid_item.ensure_visible
				if a_selected then
					if l_grid.is_single_item_selection_enabled then
						l_grid_item.enable_select
					elseif l_grid.is_single_row_selection_enabled then
						l_grid_item.row.enable_select
					end
				end
			end
		end

	editor_token_grid_support: EB_EDITOR_TOKEN_GRID_SUPPORT
			-- Supports editor token grid

	text_of_grid_item (a_item: EV_GRID_ITEM): STRING is
			-- Text of `a_item'		
		local
			l_item: EB_METRIC_GRID_RESULT_ITEM
		do
			l_item ?= a_item
			if l_item /= Void then
				Result := l_item.image
			end
		end

	select_all_action is
			-- Action to be performed to select all items in `result_grid'					
		local
			l_row_index: INTEGER
			l_row_count: INTEGER
			l_grid: like result_grid
			l_row: EV_GRID_ROW
		do
			l_grid := result_grid
			from
				l_row_index := 1
				l_row_count := l_grid.row_count
			until
				l_row_index > l_row_count
			loop
				l_row := l_grid.row (l_row_index)
				if l_row.item (1) = Void then
					l_row.set_item (1, item_function (1, l_row_index))
				end
				if l_row.item (2) = Void then
					l_row.set_item (2, item_function (2, l_row_index))
				end
				l_grid.select_row (l_row_index)
				l_row_index := l_row_index + 1
			end
		end

	is_first_display: BOOLEAN
			-- Is first display metric result?

feature{NONE} -- Implementation

	on_color_or_font_changed is
			-- Action to be performed when color or font used to display editor tokens changes
		do
			if result_grid.is_displayed then
				refresh_grid
			end
		end

	on_pointer_double_click_on_metric_name_text (a_x, a_y, a_button: INTEGER; a_x_tilt, a_y_tilt, a_pressure: DOUBLE; a_screen_x, a_screen_y: INTEGER) is
			-- Action to be performed when pointer double clicks on `metric_name_text'
		local
			l_metric: EB_METRIC
			l_metric_name: STRING
		do
			if a_button = 1 then
				l_metric_name := metric_name_text.text
				if metric_manager.has_metric (l_metric_name) then
					l_metric := metric_manager.metric_with_name (l_metric_name)
					metric_tool.go_to_definition (l_metric, False)
				end
			end
		end

	on_filter_result is
			-- Action to be performed when `filter_invisible_items_btn' is pressed.
		do
			if filter_invisible_item_btn.is_selected then
				remove_invisible_items_from_domain
			else
				restore_invisible_items_to_domain
			end
			if last_comparator /= Void then
				sort_domain (last_comparator)
			end
			refresh_grid
		end

	on_show_percentage_changes is
			-- Action to be performed when selection status of `show_percentage_btn' changes
		local
			l_double: DOUBLE_REF
		do
			if show_percentage_btn.is_sensitive then
				l_double ?= value_text.data
				if l_double /= Void then
					value_text.set_text (metric_value (l_double.item, show_percentage_btn.is_selected))
				end
			end
			if preferences.metric_tool_data.is_percentage_for_ratio_displayed /= show_percentage_btn.is_selected then
				preferences.metric_tool_data.display_percentage_for_ratio_preference.set_value (show_percentage_btn.is_selected)
			end
		end

	on_show_percentage_change_from_outside is
			-- Action to be performed when show percentage for ratio metric value is changed in preference setting window			
		local
			l_btn: like show_percentage_btn
			l_double: DOUBLE_REF
		do
			l_btn := show_percentage_btn
			if preferences.metric_tool_data.is_percentage_for_ratio_displayed then
				l_btn.enable_select
			else
				l_btn.disable_select
			end
			if l_btn.is_sensitive then
				l_double ?= value_text.data
				if l_double /= Void then
					value_text.set_text (metric_value (l_double.item, show_percentage_btn.is_selected))
				end
			end
		end

	invisible_items: DS_LINKED_LIST [EB_METRIC_RESULT_ROW]
			-- List of invisible result rows

	remove_invisible_items_from_domain is
			-- Remove invisible items from `domain' and store them in `invisible_items'.
		local
			l_domain: like domain
			l_invisible_items: like invisible_items
			l_item: EB_METRIC_RESULT_ROW
		do
			l_domain := domain
			l_invisible_items := invisible_items
			if l_domain /= Void then
				from
					l_domain.start
				until
					l_domain.after
				loop
					l_item := l_domain.item_for_iteration
					if not l_item.item.is_visible then
						l_invisible_items.force_last (l_item)
						l_domain.remove_at
					else
						l_domain.forth
					end
				end
			end
		end

	restore_invisible_items_to_domain is
			-- Restore invisible items in `invisible_items' to `domain'.
		local
			l_domain: like domain
			l_invisible_items: like invisible_items
		do
			l_domain := domain
			l_invisible_items := invisible_items
			if not l_invisible_items.is_empty then
				l_domain.finish
				l_domain.extend_right (l_invisible_items)
				l_invisible_items.wipe_out
			end
		end

	last_comparator: AGENT_LIST_COMPARATOR [EB_METRIC_RESULT_ROW]
			-- Last comparator

	on_show_percentage_change_from_outside_agent: PROCEDURE [ANY, TUPLE]
			-- Agent of `on_show_precentage_change_from_outside'

feature {NONE} -- Recycle

	internal_recycle is
			-- To be called when the button has became useless.
		do
			if quick_search_bar /= Void then
				quick_search_bar.recycle
			end
			quick_search_bar := Void
			editor_token_grid_support.desynchronize_color_or_font_change_with_editor
			editor_token_grid_support.desynchronize_scroll_behavior_with_editor
			preferences.metric_tool_data.display_percentage_for_ratio_preference.change_actions.prune_all (on_show_percentage_change_from_outside_agent)
		end

invariant
	content_attached: content /= Void
	input_grid_attached: input_grid /= Void
	result_grid_attached: result_grid /= Void
	grid_wrapper_attached: grid_wrapper /= Void
	editor_token_grid_support_attached: editor_token_grid_support /= Void
	metric_panel_attached: metric_panel /= Void
	invisible_items_attached: invisible_items /= Void

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

end -- class EB_METRIC_CALCULATION_RESULT_AREA

