note
	description: "[
					Completable text field
				]"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	COMPLETABLE_TEXT_FIELD

inherit
	EV_TEXT_FIELD
		redefine
			initialize
		end

	CODE_COMPLETABLE
		undefine
			default_create,
			is_equal,
			copy
		redefine
			calculate_completion_list_width,
			possibilities_provider,
			is_focus_back_needed,
			is_char_activator_character
		end

create
	default_create,
	make_with_text

feature{NONE} -- Initialization

	initialize
			-- Initialize current.
		do
			Precursor
			initialize_code_complete
		end

feature -- Access

	possibilities_provider: COMPLETION_POSSIBILITIES_PROVIDER
			-- Possibilities provider

	can_complete_agent: FUNCTION [ANY, TUPLE [CHARACTER_32], BOOLEAN]
			-- Agent to decide if completion can start

	preferred_width_agent: FUNCTION [ANY, TUPLE, INTEGER]
			-- Preferred width

	preferred_height_agent: FUNCTION [ANY, TUPLE, INTEGER]
			-- Preferred height

feature -- Setting

	set_can_complete_agent (a_agent: like can_complete_agent)
			-- Set `can_complete_agent' with `a_agent'.
		require
			a_agent_attached: a_agent /= Void
		do
			can_complete_agent := a_agent
		ensure
			can_complete_agent_set: can_complete_agent = a_agent
		end

	set_preferred_width_agent (a_agent_width: like preferred_width_agent)
			-- Set `preferred_width_agent' and  with `a_agent'.
		do
			preferred_width_agent := a_agent_width
		ensure
			preferred_width_agent_set: preferred_width_agent = a_agent_width
		end

	set_preferred_height_agent (a_agent_height: like preferred_height_agent)
			-- Set `preferred_height_agent' and  with `a_agent'.
		do
			preferred_height_agent := a_agent_height
		ensure
			preferred_height_agent_set: preferred_height_agent = a_agent_height
		end

feature -- Status report

	completing_word: BOOLEAN = true
			-- Has user requested to complete a word.

	is_focus_back_needed: BOOLEAN
			-- Should focus be set back after code completion?
		do
			if is_destroyed then
				Result := False
			else
				Result := True
			end
		end

	is_char_activator_character (a_char: CHARACTER_32): BOOLEAN
			-- <precursor>
		do
			Result := True
			if can_complete_agent /= Void then
				Result := can_complete_agent.item ([a_char, ev_application.ctrl_pressed, ev_application.alt_pressed, ev_application.shift_pressed])
			end
		end

feature{NONE} -- Implementation

	place_post_cursor
			-- Place cursor after completion
		do
		end

	back_delete_char
			-- Back delete character.
		do
			if text_length > 0 and caret_position > 1 then
				select_region (caret_position - 1, caret_position - 1)
				delete_selection
			end
		end

	delete_char
			-- Delete character.
		do
			if text_length > 0 and caret_position <= text_length then
				select_region (caret_position, caret_position)
				delete_selection
			end
		end

	insert_string (a_str: STRING_32)
			-- Insert `a_str' at cursor position.
		do
			insert_text (a_str)
			set_caret_position (caret_position + a_str.count)
		end

	insert_char (a_char: CHARACTER_32)
			-- Insert `a_char' at cursor position.
		do
			insert_text (create {STRING_32}.make_filled (a_char, 1))
			set_caret_position (caret_position + 1)
		end

	replace_char (a_char: CHARACTER_32)
			-- Replace current char with `a_char'.
		do
			delete_char
			insert_text (a_char.out)
		end

	block_focus_in_actions
			-- Block focus in actions
		do
			focus_in_actions.block
		end

	resume_focus_in_actions
			-- Resume focus in actions
		do
			focus_in_actions.resume
		end

	block_focus_out_actions
			-- Block focus out actions.
		do
			focus_out_actions.block
		end

	resume_focus_out_actions
			-- Resume focus out actions.
		do
			focus_out_actions.resume
		end

	handle_character (a_char: CHARACTER_32)
			-- Handle `a_char'
		do
			if not unwanted_characters.item (a_char.code) then
				insert_char (a_char)
			end
		end

	handle_extended_ctrled_key (ev_key: EV_KEY)
 			-- Process the push on Ctrl + an extended key.
 		do
 		end

	handle_extended_key (ev_key: EV_KEY)
 			-- Process the push on an extended key.
 		do
			if ev_key.code = 40 then -- Backspace
				back_delete_char
			elseif ev_key.code = 67 then -- Delete
				delete_char
			end
 		end

	remove_keyed_character (a_key: EV_KEY)
			-- We remove the 'key' character on windows platform.
			-- On linux the key has not been inserted.
			-- Fix needed.
		require
			a_key_not_void: a_key /= Void
		do
			if not {PLATFORM}.is_unix then
				if caret_position > 1 then
					if is_same_key (a_key, text.item_code (caret_position - 1)) then
						back_delete_char
					end
				end
			end
		end

	is_same_key (a_key: EV_KEY; a_char_code: INTEGER): BOOLEAN
			-- Is `a_key' a `a_char_code' character?
		require
			a_key_not_void: a_key /= Void
		local
			l_string: STRING_32
			l_keys: EV_KEY_CONSTANTS
		do
			create l_keys
			l_string := l_keys.key_strings.item (a_key.code)
			if l_string /= Void then
				if l_string.count = 1 then
					if l_string.item_code (1) = a_char_code and then a_char_code /= ('.').code then
						Result := True
					end
				elseif l_string.is_equal ("Space") then
					Result := True
				elseif a_key.is_numpad then
					if l_string.item_code (l_string.count) = a_char_code then
						Result := True
					end
				end
			end
		end

feature{NONE} -- Position calculation

	calculate_completion_list_x_position: INTEGER
			-- Determine the x position to display the completion list
		local
			screen: EV_SCREEN
			right_space,
			list_width: INTEGER
			l_font: EV_FONT
			l_text_before_cursor: STRING_32
		do
			create screen

				-- Get current x position of cursor
			l_font := font
			l_text_before_cursor := text.substring (1, caret_position)
			Result := screen_x + l_font.string_width (l_text_before_cursor)

				-- Determine how much room there is free on the right of the screen from the cursor position
			right_space := screen.virtual_right - Result - completion_border_size

			list_width := calculate_completion_list_width

			if right_space < list_width then
					-- Shift x pos back so it fits on the screen
				Result := Result - (list_width - right_space)
			end
			Result := Result.max (0)
		end

	calculate_completion_list_y_position: INTEGER
			-- Determine the y position to display the completion list
		local
			screen: EV_SCREEN
			preferred_height,
			upper_space,
			lower_space: INTEGER
			show_below: BOOLEAN
		do
				-- Get y pos of cursor
			create screen
			show_below := True
			Result := screen_y

			if Result < ((screen.virtual_height / 3) * 2) then
					-- Cursor in upper two thirds of screen
				show_below := True
			else
					-- Cursor in lower third of screen
				show_below := False
			end

			upper_space := Result - completion_border_size
			lower_space := screen.virtual_bottom - Result - completion_border_size

			if attached preferred_height_agent as l_agent then
				preferred_height := l_agent.item (Void)
			end

			if show_below and then preferred_height > lower_space and then preferred_height <= upper_space then
					-- Not enough room to show below, but is enough room to show above, so we will show above
				show_below := False
			elseif not show_below and then preferred_height <= lower_space then
					-- Even though we are in the bottom 3rd of the screen we can actually show below because
					-- the saved size fits
				show_below := True
			end

			if show_below and then preferred_height > lower_space then
					-- Not enough room to show below so we must resize
				preferred_height := lower_space
			elseif not show_below and then preferred_height >= upper_space then
					-- Not enough room to show above so we must resize
				preferred_height := upper_space
			end
			if show_below then
				Result := Result + height
			else
				Result := Result - preferred_height
			end
		end

	calculate_completion_list_height: INTEGER
			-- Determine the height the completion should list should have
		local
			upper_space,
			lower_space,
			y_pos: INTEGER
			screen: EV_SCREEN
			show_below: BOOLEAN
		do
				-- Get y pos of cursor
			create screen
			show_below := True
			y_pos := screen_y

			if y_pos < ((screen.virtual_height / 3) * 2) then
					-- Cursor in upper two thirds of screen
				show_below := True
			else
					-- Cursor in lower third of screen
				show_below := False
			end

			upper_space := y_pos - completion_border_size
			lower_space := screen.virtual_bottom - y_pos - completion_border_size

			if attached preferred_height_agent as l_agent then
				Result := l_agent.item (Void)
			end

			if show_below and then Result > lower_space and then Result <= upper_space then
					-- Not enough room to show below, but is enough room to show above, so we will show above
				show_below := False
			elseif not show_below and then Result <= lower_space then
					-- Even though we are in the bottom 3rd of the screen we can actually show below because
					-- the saved size fits
				show_below := True
			end

			if show_below and then Result > lower_space then
					-- Not enough room to show below so we must resize
				Result := lower_space
			elseif not show_below and then Result >= upper_space then
					-- Not enough room to show above so we must resize
				Result := upper_space
			end
		end

	calculate_completion_list_width: INTEGER
			-- Determine the width the completion list should have			
		do
			if attached preferred_width_agent as l_agent then
				Result := l_agent.item (Void)
			end
		end

note
	copyright: "Copyright (c) 1984-2012, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"
end