indexing
	description: "Objects that represent an EV_DIALOG.%
		%The original version of this class was generated by EiffelBuild."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	VALIDATOR_TOOL_DIALOG_IMP

inherit
	EV_DIALOG
		redefine
			initialize, is_in_default_state
		end
			
	CONSTANTS
		undefine
			is_equal, default_create, copy
		end

-- This class is the implementation of an EV_DIALOG generated by EiffelBuild.
-- You should not modify this code by hand, as it will be re-generated every time
-- modifications are made to the project.

feature {NONE}-- Initialization

	initialize is
			-- Initialize `Current'.
		do
			Precursor {EV_DIALOG}
			initialize_constants
			
				-- Create all widgets.
			create l_ev_vertical_box_1
			create l_ev_vertical_box_2
			create l_ev_label_1
			create l_ev_vertical_box_3
			create xml_radio
			create schema_radio
			create link_radio
			create spell_check_button
			create link_radio_box
			create document_tree_box
			create l_ev_horizontal_box_1
			create l_ev_cell_1
			create apply_bt
			create okay_bt
			create cancel_bt
			
				-- Build_widget_structure.
			extend (l_ev_vertical_box_1)
			l_ev_vertical_box_1.extend (l_ev_vertical_box_2)
			l_ev_vertical_box_2.extend (l_ev_label_1)
			l_ev_vertical_box_1.extend (l_ev_vertical_box_3)
			l_ev_vertical_box_3.extend (xml_radio)
			l_ev_vertical_box_3.extend (schema_radio)
			l_ev_vertical_box_3.extend (link_radio)
			l_ev_vertical_box_3.extend (spell_check_button)
			l_ev_vertical_box_3.extend (link_radio_box)
			l_ev_vertical_box_1.extend (document_tree_box)
			l_ev_vertical_box_1.extend (l_ev_horizontal_box_1)
			l_ev_horizontal_box_1.extend (l_ev_cell_1)
			l_ev_horizontal_box_1.extend (apply_bt)
			l_ev_horizontal_box_1.extend (okay_bt)
			l_ev_horizontal_box_1.extend (cancel_bt)
			
			set_minimum_width (dialog_width)
			set_minimum_height (dialog_height)
			set_title ("Validator")
			l_ev_vertical_box_1.set_padding_width (5)
			l_ev_vertical_box_1.set_border_width (2)
			l_ev_vertical_box_1.disable_item_expand (l_ev_vertical_box_2)
			l_ev_vertical_box_1.disable_item_expand (l_ev_vertical_box_3)
			l_ev_vertical_box_1.disable_item_expand (l_ev_horizontal_box_1)
			l_ev_vertical_box_2.set_padding_width (5)
			l_ev_vertical_box_2.set_border_width (inner_border_width)
			l_ev_vertical_box_2.disable_item_expand (l_ev_label_1)
			l_ev_label_1.set_text ("Select the type of validation you would like to perform on the currently%Nloaded project:")
			l_ev_label_1.align_text_left
			l_ev_vertical_box_3.set_padding_width (5)
			l_ev_vertical_box_3.set_border_width (inner_border_width)
			l_ev_vertical_box_3.disable_item_expand (xml_radio)
			l_ev_vertical_box_3.disable_item_expand (schema_radio)
			l_ev_vertical_box_3.disable_item_expand (link_radio)
			l_ev_vertical_box_3.disable_item_expand (spell_check_button)
			xml_radio.set_text ("Validate project documents as XML")
			schema_radio.set_text ("Validate project documents against schema definition")
			link_radio.set_text ("Validate document links")
			spell_check_button.set_text ("Spell check all documents")
			link_radio_box.disable_sensitive
			link_radio_box.set_padding_width (5)
			link_radio_box.set_border_width (inner_border_width)
			l_ev_horizontal_box_1.set_padding_width (5)
			l_ev_horizontal_box_1.set_border_width (2)
			l_ev_horizontal_box_1.disable_item_expand (apply_bt)
			l_ev_horizontal_box_1.disable_item_expand (okay_bt)
			l_ev_horizontal_box_1.disable_item_expand (cancel_bt)
			apply_bt.set_text ("Apply")
			apply_bt.set_minimum_width (80)
			okay_bt.set_text ("OK")
			okay_bt.set_minimum_width (80)
			cancel_bt.set_text ("Cancel")
			cancel_bt.set_minimum_width (80)
			
				--Connect events.
				-- Close the application when an interface close
				-- request is recieved on `Current'. i.e. the cross is clicked.

				-- Call `user_initialization'.
			user_initialization
		end

feature -- Access

	l_ev_vertical_box_1, l_ev_vertical_box_2, l_ev_vertical_box_3, link_radio_box, 
	document_tree_box: EV_VERTICAL_BOX
	l_ev_label_1: EV_LABEL
	xml_radio, schema_radio, link_radio, spell_check_button: EV_RADIO_BUTTON
	l_ev_horizontal_box_1: EV_HORIZONTAL_BOX
	l_ev_cell_1: EV_CELL
	apply_bt, okay_bt, cancel_bt: EV_BUTTON

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
		
	
end -- class VALIDATOR_TOOL_DIALOG_IMP
