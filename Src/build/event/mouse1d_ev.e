
class MOUSE1D_EV 

inherit

	EVENT

creation

	make
	
feature 

	identifier: INTEGER is
		do
			Result := - Event_const.mouse1d_ev_id
		end;

	symbol: PIXMAP is
		do
			Result := Pixmaps.mouse1d_pixmap
		end;

	internal_name: STRING is
		do
			Result := Event_const.mouse1d_label
		end;

	eiffel_text: STRING is "add_button_press_action (1, ";	

	specific_add (a_widget: WIDGET; a_command: COMMAND) is
			-- Add	`a_command' to `a_widget' according to the 
			-- kind of event.
		do
			a_widget.add_button_press_action (1, a_command, Void)
		end

	specific_remove (a_widget: WIDGET; a_command: COMMAND	) is
			-- Remove `a_command' from `a_widget' according to the
			-- kind of event.
		do
			a_widget.remove_button_press_action (1, a_command, Void)
		end

end
