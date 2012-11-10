note
	description: "[
		Editor pick n drop.
		Uses a tool to make feature text clickable.
	]"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	EB_CLICKABLE_EDITOR

inherit
	EB_CUSTOM_WIDGETTED_EDITOR
		export
			{EB_ROUTINE_FLAT_FORMATTER} invalidate_line
		redefine
			make,
			reset, on_text_loaded,
			on_text_block_loaded,
			gain_focus,
			on_mouse_button_down,
			on_click_in_text, handle_extended_key,
			handle_extended_ctrled_key,
			text_displayed,
			copy_selection,
			internal_recycle,
			internal_detach_entities,
			margin,
			cursor_type,
			line_type
		end

	EB_FORMATTED_TEXT
		rename
			text as text_from_formatted_text
		export
			{NONE} All
		undefine
			clear_window, reset, default_create
		end

	EB_CONSTANTS
		export
			{NONE} all
		undefine
			default_create
		end

create
	make

feature {NONE}-- Initialization

	make (a_dev_window: EB_DEVELOPMENT_WINDOW)
			-- Initialize the editor.
		local
			l_dev_win: EB_DEVELOPMENT_WINDOW
		do
			Precursor {EB_CUSTOM_WIDGETTED_EDITOR} (a_dev_window)
			if dev_window /= Void then
					-- Register the dev_window as an observer of `Current'
				text_displayed.add_selection_observer (dev_window.agents)
			end
			create after_reading_text_actions.make
			after_reading_text_actions.compare_objects

			editor_drawing_area.set_pebble_function (agent pebble_from_x_y)
			editor_drawing_area.enable_pebble_positioning
			editor_drawing_area.drop_actions.extend (agent resume_cursor_for_drop)
				-- Always refuse pick and drop by default if user does not add its own `drop_actions'.
			editor_drawing_area.drop_actions.set_veto_pebble_function (agent (a: ANY): BOOLEAN do Result := False end)
			editor_drawing_area.pick_actions.force_extend (agent suspend_cursor_blinking)
			editor_drawing_area.pick_ended_actions.force_extend (agent resume_cursor_blinking)

				-- Not necessarily use `a_dev_window' to get context menu.
				-- `a_dev_window' could be void for some uses.
			l_dev_win := a_dev_window
			if l_dev_win = Void then
				l_dev_win := window_manager.last_focused_development_window
			end
			if l_dev_win /= Void then
				editor_drawing_area.set_configurable_target_menu_mode
				editor_drawing_area.set_configurable_target_menu_handler (agent (l_dev_win.menus.context_menu_factory).editor_menu (?, ?, ?, ?, Current))
			end

		end

feature -- Access

	text_length: INTEGER
			-- Length of displayed text.
		do
			Result := text_displayed.text_length
		end

	position: INTEGER
			-- Current cursor position.
		do
			if not text_displayed.is_empty then
				Result := text_displayed.cursor.pos_in_text
			end
		end

	margin: EB_CLICKABLE_MARGIN
			-- Margin widget for breakpoints, line numbers, etc. This is different to the left margin
			-- used in the editor for spacing purposes.		

feature -- Content Change

	handle_before_processing (append: BOOLEAN)
			-- Reinitialize editor if not `append' so that new content be received
			-- If `append' we only reset related flags.
			-- Only we treat `text_displayed' as TEXT_FORMATTER, we need to call this method.
		do
			editor_viewport.disable_sensitive

				-- Reset the editor state
			if not append then
					-- Load empty text to hold the invariant of the editor.
				load_text ("")
			end
			allow_edition := False

				-- Read and parse the text.
			text_displayed.set_first_read_block_size (number_of_lines_in_block)
			text_displayed.start_processing (append)
		end

	handle_after_processing
			-- Setup editor after processing.
			-- Editor interface is reinitialized, text observer methods are called.
			-- Only we treat `text_displayed' as TEXT_FORMATTER, we need to call this method.
		do
			text_displayed.end_processing
			if not editor_set then
				setup_editor (1)
				editor_set := true
			else
				update_vertical_scrollbar
				update_horizontal_scrollbar
				update_width
				set_editor_width (editor_width)
				update_horizontal_scrollbar
				refresh_now
				margin.refresh_now
			end
			editor_viewport.enable_sensitive
		end

feature -- Status setting

	enable_has_breakable_slots
			-- Set `has_breakable_slots' to `True' and update display.
		do
			margin.show_breakpoints
			refresh_margin
		end

	disable_has_breakable_slots
			-- Set `has_breakable_slots' to `False' and update display.
		do
			margin.hide_breakpoints
			refresh_margin
		end

feature -- Possibly delayed operations

	display_line_when_ready (l_num: INTEGER; a_col: INTEGER; highlight: BOOLEAN)
			-- same as select_region but scroll to the selected position
			-- (beginning of selection at then bottom of the editor) and
			-- does not need the text to be fully loaded			
		do
			if text_is_fully_loaded then
				if l_num > 0 and then l_num <= number_of_lines then
					if highlight then
						if a_col > 0 then
							text_displayed.select_token (l_num, a_col)
						else
							text_displayed.select_line (l_num)
						end
					end
					if highlight and has_selection then
						show_selection (False)
					else
						display_line_with_context (l_num)
					end
					refresh_now
				end
			else
				after_reading_text_actions.extend (agent display_line_when_ready (l_num, a_col, highlight))
			end
		end

	display_line_at_top_when_ready (l_num: INTEGER; a_col: INTEGER)
			-- same as select_region but scroll to the selected position
			-- (beginning of selection at then bottom of the editor) and
			-- does not need the text to be fully loaded
		local
			ln: INTEGER
		do
			if text_is_fully_loaded then
				ln := l_num.min (maximum_top_line_index)
				set_first_line_displayed (ln, True)
				if a_col > 0 then
					text_displayed.cursor.set_x_in_characters (a_col)
				end
				refresh_now
			else
				after_reading_text_actions.extend(agent display_line_at_top_when_ready (l_num, a_col))
			end
		end

	highlight_when_ready (a, b: INTEGER)
			-- same as select_lines but scroll to the selected position
			-- (beginning of selection at then bottom of the editor) and
			-- does not need the text to be fully loaded	
		local
			fld: INTEGER
			max_line: INTEGER
		do
			if text_is_fully_loaded then
				max_line := text_displayed.number_of_lines
				select_lines (a.min (max_line), b.min (max_line))
				if number_of_lines > number_of_lines_displayed then
					fld := text_displayed.selection_start.y_in_lines - number_of_lines_displayed + (number_of_lines_displayed // 2).min(2)
					fld := fld.max (1).min (maximum_top_line_index)
					set_first_line_displayed (fld, True)
				end
			else
				after_reading_text_actions.extend(agent highlight_when_ready (a, b))
			end
		end

	scroll_to_when_ready (pos: INTEGER)
			-- scroll to position `pos' in characters
			-- does not need the text to be fully loaded
		local
			cursor: like cursor_type
		do
			if text_is_fully_loaded then
				cursor := text_displayed.cursor
				if cursor /= Void then
					if text_displayed.has_selection then
						text_displayed.disable_selection
					end
					cursor.set_from_integer (pos.min (text_displayed.text_length).max (1), text_displayed)
					if number_of_lines > number_of_lines_displayed then
						set_first_line_displayed (cursor.y_in_lines.min (maximum_top_line_index), True)
						check_position (cursor)
					end
				end
				refresh
			else
				after_reading_text_actions.extend(agent scroll_to_when_ready (pos))
			end
		end

	select_region_when_ready (a_start_pos, a_end_pos: INTEGER)
			-- Select region between `a_start_pos' and `a_end_pos' when text is fully loaded.
		do
			if text_is_fully_loaded then
				select_region (a_start_pos, a_end_pos)
				show_selection (True)
			else
				after_reading_text_actions.extend (agent select_region_when_ready (a_start_pos, a_end_pos))
			end
		end

	scroll_to_start_of_line_when_ready_if_top (a_line_number: INTEGER; a_column_number: INTEGER; a_selected: BOOLEAN; a_top: BOOLEAN)
			-- Scroll to `a_line_number'-th line.
			-- If `a_selected' is True, select that line.
			-- If `a_top' then display `a_line_number' at top.
		local
			l_text: like text_displayed
			l_col: INTEGER
		do
			if text_is_fully_loaded then
				l_text := text_displayed
				if l_text.has_selection then
					l_text.forget_selection
				end
				l_text.cursor.set_y_in_lines (a_line_number)
				l_text.cursor.go_start_line
				if a_column_number = 0 then
					l_text.cursor.go_smart_home
					l_col := l_text.cursor.pos_in_characters
				else
					l_col := a_column_number
				end
				if a_top then
					display_line_at_top_when_ready  (a_line_number, l_col)
				else
					display_line_when_ready (a_line_number, l_col, a_selected)
				end
			else
				after_reading_text_actions.extend (agent scroll_to_start_of_line_when_ready (a_line_number, a_column_number, a_selected))
			end
		end

	scroll_to_start_of_line_when_ready (a_line_number: INTEGER; a_column_number: INTEGER; a_selected: BOOLEAN)
			-- Scroll to `a_line_number'-th line.
			-- If `a_selected' is True, select that line.
		do
			scroll_to_start_of_line_when_ready_if_top (a_line_number, a_column_number, a_selected, False)
		end

	scroll_to_end_when_ready
			-- scroll to position `pos' in characters
			-- does not need the text to be fully loaded
		local
			l_deferred_action: PROCEDURE [EB_CLICKABLE_EDITOR, TUPLE]
		do
			if text_is_fully_loaded and text_displayed.cursor /= Void then
				if text_displayed.has_selection then
					text_displayed.disable_selection
				end
				text_displayed.cursor.set_from_character_pos (1, number_of_lines, text_displayed)
				if number_of_lines > number_of_lines_displayed then
					check_cursor_position
				end
				refresh
			else
				l_deferred_action := agent scroll_to_end_when_ready
				if not after_reading_text_actions.has (l_deferred_action) then
						-- Ensure the scroll action is not added twice.
					after_reading_text_actions.extend (l_deferred_action)
				end
			end
		end

	display_breakpoint_number_when_ready (bpn: INTEGER; feat_id: INTEGER)
			-- scroll to position `pos' in characters
			-- does not need the text to be fully loaded			
		do
			if text_is_fully_loaded then
				display_breakpoint_number (bpn, feat_id)
			else
				after_reading_text_actions.extend(agent display_breakpoint_number (bpn, feat_id))
			end
		end

feature -- Compatibility

	set_position (a_position: INTEGER)
			-- Set cursor position to `a_position'.
		do
			text_displayed.set_position (a_position)
		end

	put_string (s: READABLE_STRING_GENERAL)
			-- Put string `s' at current position.
		do
			text_displayed.add_string (s)
		end

	put_char (c: CHARACTER_32)
			-- Put a character `c' at current position.
		do
			text_displayed.add_char (c)
		end

	put_new_line
			-- Put a new line at current position.
		do
			text_displayed.add_new_line
		end

	copy_selection
			-- Copy current selection to clipboard.
		do
			Precursor {EB_CUSTOM_WIDGETTED_EDITOR}
			if dev_window /= Void then
				dev_window.update_paste_cmd
			end
		end

feature {EB_FEATURE_INFO_FORMATTER} -- Feature click tool

	enable_feature_click
			-- enable feature click tool		
		do
			text_displayed.enable_feature_click
		end

	disable_feature_click
			-- disable feature click tool					
		do
			text_displayed.disable_feature_click
		end

	set_feature_for_click (feat: E_FEATURE)
			-- initialize feature click tool with feature `feat'
		do
			text_displayed.set_feature_for_click (feat)
		end

	feature_click_enabled: BOOLEAN
			-- do we use feature click tool?
		do
			Result := text_displayed.feature_click_enabled
		end

feature {EB_CLICKABLE_MARGIN}-- Process Vision2 Events

	on_mouse_button_down (abs_x_pos, y_pos, button: INTEGER; unused1,unused2,unused3: DOUBLE; a_screen_x, a_screen_y: INTEGER)
			-- Process single click on mouse buttons.
		do
			if not is_recycled then
				Precursor {EB_CUSTOM_WIDGETTED_EDITOR} (abs_x_pos, y_pos, button, unused1, unused2, unused3, a_screen_x, a_screen_y)
			end
		end

	on_click_in_text (x_pos, y_pos, button: INTEGER; a_screen_x, a_screen_y: INTEGER)
			-- Process click on the text. `x_pos' and `y_pos' are coordinates relative to the upper left
			-- left corner of the text, i.e. margin width and offset have already been added/substracted to them.
			-- `a_screen_x' and `a_screen_y' are the mouse pointer absolute coordinates on the screen.
		local
			l_number: INTEGER
			ln: like line_type
			l_stone: STONE
			bkstn: BREAKABLE_STONE
			cur: like cursor_type
		do
			if button = 1 then
				Precursor {EB_CUSTOM_WIDGETTED_EDITOR} (x_pos, y_pos, button, a_screen_x, a_screen_y)
			elseif button = 3 then
				mouse_right_button_down := True
				if x_pos <= 0 then
					l_number := ((y_pos - editor_viewport.y_offset) // line_height) + first_line_displayed
					if text_displayed.number_of_lines >= l_number then
						ln ?= text_displayed.line (l_number)
						bkstn ?= ln.real_first_token.pebble
					end
					create cur.make_from_character_pos (1, 1, text_displayed)
					position_cursor (cur, 1, y_pos - editor_viewport.y_offset)
				else
					create cur.make_from_character_pos (1, 1, text_displayed)
					position_cursor (cur, x_pos, y_pos - editor_viewport.y_offset)
					bkstn ?= cur.token.pebble
				end
				if bkstn = Void then
					if ctrled_key then
						l_stone := text_displayed.stone_at (cur)
						if l_stone /= Void and then l_stone.is_valid then
							(create {EB_CONTROL_PICK_HANDLER}).launch_stone (l_stone)
						end
					end
				else
					check
						cursor_not_void: text_displayed.cursor /= Void
					end
					text_displayed.cursor.set_from_character_pos (cur.x_in_characters, cur.y_in_lines, text_displayed)
					bkstn.display_bkpt_menu
					mouse_right_button_down := False
					mouse_left_button_down := False
					refresh_now
				end
			end
		end

	handle_extended_key (ev_key: EV_KEY)
 			-- Process the push on an extended key.
		local
			l_shortcuts: like matching_customizable_commands
			l_x_offset, l_y_offset: INTEGER
		do
			l_shortcuts := matching_customizable_commands (ev_key.code, ctrled_key, alt_key, shifted_key)
				--| Fixme: When l_shortcuts is not empty, l_short_cuts.first can be void.
			if not l_shortcuts.is_empty and then l_shortcuts.first /= Void then
				l_shortcuts.first.apply
				check_cursor_position
			elseif ev_key.code = {EV_KEY_CONSTANTS}.key_menu then
				if not text_displayed.is_empty then
					check_cursor_position
					l_x_offset := current_cursor_position + left_margin_width
					l_y_offset := (text_displayed.cursor.y_in_lines - first_line_displayed + 1) *
						line_height + editor_viewport.y_offset - 1
					editor_drawing_area.show_configurable_target_menu (l_x_offset, l_y_offset)
				end
			else
				Precursor {EB_CUSTOM_WIDGETTED_EDITOR} (ev_key)
			end
		end

	handle_extended_ctrled_key (ev_key: EV_KEY)
 			-- Process the push on Ctrl + an extended key.
		local
			l_shortcuts: like matching_customizable_commands
		do
			l_shortcuts := matching_customizable_commands (ev_key.code, True, alt_key, shifted_key)
				--| Fixme: When l_shortcuts is not empty, l_short_cuts.first can be void.
			if not l_shortcuts.is_empty and then l_shortcuts.first /= Void then
				l_shortcuts.first.apply
				check_cursor_position
			else
				Precursor {EB_CUSTOM_WIDGETTED_EDITOR} (ev_key)
			end
		end

feature {EB_CLICKABLE_MARGIN} -- Pick and drop

	pebble_from_x_y (x_pos_with_margin, abs_y_pos: INTEGER): STONE
			-- Stone on (`x_pos', `y_pos').
		local
			cur			: like cursor_type
			l_number	: INTEGER
			x_pos,
			y_pos		: INTEGER
			token_pos	: INTEGER
			bkst		: BREAKABLE_STONE
			old_offset	: INTEGER
			l_line		: INTEGER
			l_update_selection: BOOLEAN
			l_dev_win	: like dev_window
		do
			if not (ctrled_key or else mouse_copy_cut) then
				if not text_displayed.is_empty then
					x_pos := x_pos_with_margin - left_margin_width
					y_pos := abs_y_pos - editor_viewport.y_offset

						-- Compute the line number pointed by the mouse cursor
						-- and adjust it if its over the number of lines in the text.
					l_number := (y_pos // line_height) + first_line_displayed
					if
						l_number > 0 and then
						l_number <= number_of_lines and then
						x_pos >= -left_margin_width + offset and then
						x_pos < editor_viewport.width + offset
					then
						create cur.make_from_character_pos (1, 1, text_displayed)
						position_cursor (cur, x_pos, y_pos)
						Result := text_displayed.stone_at (cur)
						if Result = Void then
							position_cursor (cur, x_pos -1, y_pos)
							Result := text_displayed.stone_at (cur)
								-- Restore cursor position.
							position_cursor (cur, x_pos, y_pos)
						end
							-- Are we outside a selection?
						l_update_selection := not text_displayed.has_selection or else
							(text_displayed.selection_start > cur or text_displayed.selection_end < cur)
						if Result /= Void and then Result.is_valid then
								-- FIXME: Is it really possible to have a BREAKABLE_STONE?
							bkst ?= Result
							if bkst = Void then
								l_number := cur.y_in_lines
								token_pos := cur.token.position
									-- Pick and drop mode, we set the selection to the pebble.
								l_dev_win := dev_window
								if l_dev_win = Void then
									l_dev_win := window_manager.last_focused_development_window
								end
								if l_dev_win /= Void and then not l_dev_win.menus.context_menu_factory.menu_displayable (Result) then
									if text_displayed.has_selection then
	  									text_displayed.disable_selection
	  									invalidate_block (text_displayed.selection_start.y_in_lines, text_displayed.selection_end.y_in_lines, False)
									else
										invalidate_line (text_displayed.cursor.y_in_lines, False)
									end
									l_line := text_displayed.current_line_number
									cur.set_current_char (cur.token, 1)
									text_displayed.cursor.set_from_character_pos (cur.x_in_characters, l_number, text_displayed)
									text_displayed.selection_cursor.set_from_character_pos (cur.x_in_characters + cur.token.length, l_number, text_displayed)
									text_displayed.enable_selection
									old_offset := offset
									invalidate_line (l_number, False)
									invalidate_line (l_line, False)
									l_update_selection := False
								end
								check_position (cur)
								editor_drawing_area.set_pebble_position (token_pos + left_margin_width, (l_number - first_line_displayed)*line_height + line_height//2 + editor_viewport.y_offset)
								if Result.stone_cursor /= Void then
									editor_drawing_area.set_accept_cursor (Result.stone_cursor)
								end
								if Result.x_stone_cursor /= Void then
									editor_drawing_area.set_deny_cursor (Result.x_stone_cursor)
								end
							else
								Result := Void
							end
						else
							Result := Void
						end
						if l_update_selection then
							text_displayed.disable_selection
							l_line := text_displayed.selection_start.y_in_lines
							l_number := text_displayed.selection_end.y_in_lines
							text_displayed.cursor.set_from_character_pos (cur.x_in_characters, cur.y_in_lines, text_displayed)
							text_displayed.set_selection_cursor (text_displayed.cursor)
							invalidate_block (l_line, l_number, False)
						end
					end
				end
			end
		end

feature {NONE} -- Text Loading

	reset
			-- Reinitialize `Current' so that it can receive a new content.
		do
				-- First abort our previous actions.
			Precursor {EB_CUSTOM_WIDGETTED_EDITOR}
			if attached internal_search_tool then
				internal_search_tool.force_new_search
			end
			after_reading_text_actions.wipe_out
		end

	on_text_loaded
			-- Finish editor setup as the entire text has been loaded.
		do
			Precursor {EB_CUSTOM_WIDGETTED_EDITOR}
			from
				after_reading_text_actions.start
			until
				after_reading_text_actions.after
			loop
				after_reading_text_actions.item.call(Void)
				after_reading_text_actions.forth
			end
			after_reading_text_actions.wipe_out
		end

	on_text_block_loaded (was_first_block: BOOLEAN)
			-- Update scroll bar as a new block of text as been loaded.
		local
			l_line: INTEGER
		do
			Precursor {EB_CUSTOM_WIDGETTED_EDITOR} (was_first_block)
				-- Show the first block.
			if was_first_block then
				if first_line_displayed > 0 and then first_line_displayed <= number_of_lines then
					l_line := first_line_displayed
				else
					l_line := 1
				end
				setup_editor (l_line)
			end
		end

feature -- Update

	on_text_saved
			-- Update the editor as the text has been saved.
		local
			fn: STRING_32
			backup_file: RAW_FILE
			file: RAW_FILE
		do
			text_displayed.set_changed (False, True)
			if open_backup then
				fn := file_name.string_representation
				create backup_file.make_with_path (file_name)
				if backup_file.exists then
					backup_file.delete
				end
				fn.keep_head (fn.count - 4)
				create file_name.make_from_string (fn)
				open_backup := False
			end
			if file_name /= Void then
				create file.make_with_path (file_name)
				if file.exists then
					date_of_file_when_loaded := file.date
					size_of_file_when_loaded := file_size
				end
			end
		end

feature -- Access

	text_displayed: CLICKABLE_TEXT
			-- Text displayed in the editor.

feature {NONE} -- Implementation

	after_reading_text_actions: LINKED_LIST [PROCEDURE [EB_CLICKABLE_EDITOR, TUPLE]]
			-- Procedures to be applied when the text is completely loaded.

	hidden_breakpoints: BOOLEAN
			-- Are brekpoints hidden ?

	matching_customizable_commands (key_code: INTEGER; ctrl, alt, shift: BOOLEAN): ACTION_SEQUENCE [TUPLE]
			-- List of shortcuts agents in `customizable_commands' that correspond to the shortcut
			-- defined by key of code `key_code' and Ctrl if `ctrl', Shift if `shift' and Alt if `alt'.
		local
			l_shortcut: SHORTCUT_PREFERENCE
			l_shortcuts: HASH_TABLE [SHORTCUT_PREFERENCE, STRING]
		do
			create Result
			l_shortcuts := preferences.editor_data.shortcuts
			from
				l_shortcuts.start
			until
				l_shortcuts.after
			loop
				l_shortcut := l_shortcuts.item_for_iteration
				if l_shortcut.key.code = key_code then
					if l_shortcut.matches (create {EV_KEY}.make_with_code (key_code), alt, ctrl, shift) then
						if customizable_commands.item (l_shortcuts.key_for_iteration) /= Void then
							Result.extend (customizable_commands.item (l_shortcuts.key_for_iteration))
						end
					end
				end
				l_shortcuts.forth
			end
		ensure
			matching_customizable_commands_not_void: Result /= Void
		end

	display_breakpoint_number (bp_number: INTEGER; a_feat_id: INTEGER)
			-- Show `bp_number'-th breakpoint of feature represented by `a_feat_id'
		require
			bp_number_is_valid: bp_number > 0
			text_completely_loaded: text_is_fully_loaded
		local
			ln: like line_type
			bp_count, line_index: INTEGER
			bp_token: EDITOR_TOKEN_BREAKPOINT
		do
			from
				ln ?= text_displayed.first_line
			until
				ln = Void or else bp_count = bp_number
			loop
				bp_token ?= ln.real_first_token
				if bp_token /= Void and then bp_token.pebble /= Void then
					if bp_token.pebble.routine.feature_id = a_feat_id then
						bp_count := bp_count + 1

					end
				end
				line_index := line_index + 1
				ln := ln.next
			end
			if bp_count = bp_number then
					-- Only scroll when necessary
				if first_line_displayed > line_index or first_line_displayed + number_of_lines_displayed <= line_index then
					display_line_with_context (line_index)
				end
			else
				debug ("EDITOR")
					io.error.put_string ("%N Editor Warning : Unable to scroll to Breakpoint number "+ bp_number.out + "%N")
					io.error.put_string ("                   There are only " + bp_count.out + " in currently displayed class.%N")
				end
			end
		end

	gain_focus
			-- Update the editor as it has just gained the focus.
		do
			Precursor {EB_CUSTOM_WIDGETTED_EDITOR}
			if dev_window /= Void then
				dev_window.ui.set_current_editor (Current)
			end
		end

	in_feature_click: BOOLEAN

	resume_cursor_for_drop (a: ANY)
			-- Resumes cursor on drop from pick and drop
		do
			resume_cursor_blinking
		end

	text_from_formatted_text: STRING_32
			-- Temperary implementation
		do
			Result := wide_text
		end

feature {NONE} -- Memory management

	internal_recycle
			-- Destroy `Current'
		do
			if dev_window /= Void and then dev_window.ui.current_editor = Current then
					-- To avoid reference on recycled editor.
				dev_window.ui.set_current_editor (Void)
			end
			Precursor {EB_CUSTOM_WIDGETTED_EDITOR}
			if after_reading_text_actions /= Void then
				after_reading_text_actions.wipe_out
			end
			text_observer_manager.selection_observer_list.wipe_out
			text_observer_manager.post_notify_actions.wipe_out
			text_observer_manager.lines_observer_list.wipe_out
			text_observer_manager.edition_observer_list.wipe_out
			text_observer_manager.cursor_observer_list.wipe_out
		end

	internal_detach_entities
			-- <Precursor>
		do
			after_reading_text_actions := Void
			Precursor
		end

feature {NONE} -- Implementation

	editor_set : BOOLEAN
			-- Has editor been setup?

	line_type: EIFFEL_EDITOR_LINE
			-- Type of line.
		do
		end

	cursor_type: EIFFEL_EDITOR_CURSOR
			-- Type of cursor.
		do
		end

note
	copyright: "Copyright (c) 1984-2012, Eiffel Software"
	license:   "GPL version 2 (see http://www.eiffel.com/licensing/gpl.txt)"
	licensing_options: "http://www.eiffel.com/licensing"
	copying: "[
			This file is part of Eiffel Software's Eiffel Development Environment.
			
			Eiffel Software's Eiffel Development Environment is free
			software; you can redistribute it and/or modify it under
			the terms of the GNU General Public License as published
			by the Free Software Foundation, version 2 of the License
			(available at the URL listed under "license" above).
			
			Eiffel Software's Eiffel Development Environment is
			distributed in the hope that it will be useful, but
			WITHOUT ANY WARRANTY; without even the implied warranty
			of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
			See the GNU General Public License for more details.
			
			You should have received a copy of the GNU General Public
			License along with Eiffel Software's Eiffel Development
			Environment; if not, write to the Free Software Foundation,
			Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
		]"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"

end -- class EB_CLICKABLE_EDITOR
