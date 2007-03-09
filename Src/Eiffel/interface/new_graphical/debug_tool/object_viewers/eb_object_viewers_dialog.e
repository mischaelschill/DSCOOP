indexing
	description: "Objects that represent an EV_DIALOG.%
		%The original version of this class was generated by EiffelBuild."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	EB_OBJECT_VIEWERS_DIALOG

inherit

	EB_OBJECT_VIEWERS_I
		undefine
			default_create, copy, is_equal
		end

	EV_DIALOG
		redefine
			destroy,
			raise
		end

	EV_SHARED_APPLICATION
		undefine
			default_create, copy, is_equal
		end

	EB_CONSTANTS
		undefine
			default_create, copy, is_equal
		end

create
	make

feature {NONE} -- Initialization

	make (cmd: EB_OBJECT_VIEWER_COMMAND) is
			-- Initialize `Current'.
		require
			cmd_not_void: cmd /= Void
		local
			vb: EV_VERTICAL_BOX
			hb: EV_HORIZONTAL_BOX
			but: EV_BUTTON
		do
			command := cmd
			default_create

			create vb
			extend (vb)
			vb.set_border_width (layout_constants.small_border_size)

			create viewer_header_cell
			vb.extend (viewer_header_cell)
			vb.disable_item_expand (viewer_header_cell)

			create viewers_manager.make
			vb.extend (viewers_manager.widget)
			viewers_manager.viewer_changed_actions.extend (agent update_current_viewer)

				--| Bottom close button box			
			vb.extend (create {EV_CELL})
			vb.last.set_minimum_height (layout_constants.small_padding_size)
			vb.disable_item_expand (vb.last)

			create hb
			vb.extend (hb)
			vb.disable_item_expand (hb)
			hb.extend (create {EV_CELL})

			create but.make_with_text ("Select viewer")
			but.select_actions.extend (agent open_viewer_selector_menu (but))
			but.drop_actions.extend (agent viewers_manager.set_stone )
			but.drop_actions.set_veto_pebble_function (agent viewers_manager.is_stone_valid)

			hb.extend (but)
			hb.disable_item_expand (but)
			but.set_minimum_width (layout_constants.default_button_width)
			hb.extend (create {EV_CELL})
			create close_button.make_with_text_and_action (interface_names.b_close, agent destroy)
			close_button.set_minimum_width (layout_constants.default_button_width)

			hb.extend (close_button)
			hb.disable_item_expand (close_button)
			hb.extend (create {EV_CELL})

			if viewers_manager.title /= Void then
				set_title (viewers_manager.title)
			end
			set_icon_pixmap (pixmaps.icon_pixmaps.general_dialog_icon)
			set_default_cancel_button (close_button)

			set_size (400, 300)
		end

	update_current_viewer (v: EB_OBJECT_VIEWER) is
		local
			t: STRING_GENERAL
			w: EV_WIDGET
		do
				--| Toolbar
			if v /= Void then
				v.build_tool_bar
				w := v.tool_bar
				if w /= Void and then w.parent = Void then
						--| We don't move `tool_bar' if already parented
					viewer_header_cell.replace (w)
				end
			else
				viewer_header_cell.wipe_out
			end
				--| Title
			if v /= Void then
				t := v.title
			end
			if t = Void then
				t := viewers_manager.title
			end
			if t /= Void then
				set_title (t)
			else
				remove_title
			end
		end

feature {NONE} -- Initialization

	close_button: EV_BUTTON

	open_viewer_selector_menu (w: EV_WIDGET) is
			--
		local
			m: EV_MENU
		do
			m := viewers_manager.menu
			check m.parent = Void end
			m.show_at (w, 1, 1)
		end

feature -- Access

	viewer_header_cell: EV_CELL

	viewers_manager: EB_OBJECT_VIEWERS_MANAGER

	current_object: OBJECT_STONE is
		do
			Result := viewers_manager.current_object
		end

	refresh is
		do
			viewers_manager.refresh
		end

	set_stone (st: OBJECT_STONE) is
			-- Give a new object to `Current' and refresh the display.
		do
			viewers_manager.set_stone (st)
		end

feature -- Status setting

	close is
		do
			hide
			destroy
		end

	raise is
			-- Display `dialog' and put it in front.
		do
			Precursor
			show_relative_to_window (command.associated_window)
		end

	destroy is
			-- Destroy Current
		do
			viewers_manager.destroy
			Precursor
			command.remove_entry (Current)
		end

feature {NONE} -- Implementation

	command: EB_OBJECT_VIEWER_COMMAND;
			-- Command that created `Current' and knows about it.

invariant
	has_command: command /= Void

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

end
