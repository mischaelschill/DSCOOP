indexing

	description: 
		"Formats Eiffel class text.";
	date: "$Date$";
	revision: "$Revision $"

class CLASS_TEXT_FORMATTER

inherit

	E_TEXT_FORMATTER

feature -- Properties

	is_one_class_only: BOOLEAN;
			-- Is the format performed on one class only?
	
	is_short: BOOLEAN;
			-- Is the format doing a short? 

	ordered_same_as_text: BOOLEAN;
			-- Will the format output be in the same order as text file?

	is_flat: BOOLEAN is
			-- Is the format doing a flat? 
		do
			Result := not is_short
		ensure
			not_short: Result = not is_short
		end;

feature -- Setting

	set_is_short is
			-- Set `is_short' to True.
		do
			is_short := True
		ensure
			is_short: is_short
		end;

	set_order_same_as_text is
			-- Set ordered_same_as_text_bool to True.
		do
			ordered_same_as_text := True
		ensure
			ordered_same_as_text: ordered_same_as_text
		end;

	set_one_class_only is
			-- Set current_class_only to True.
		do
			is_one_class_only := True;
		ensure
			is_one_class_only: is_one_class_only
		end

feature -- Execution

	format (e_class: E_CLASS) is
			-- Format text for eiffel class `e_class'.
		require
			valid_e_class: e_class /= Void
		local
			f: FORMAT_CONTEXT_B
		do
			!! f.make (e_class);
			if is_short then
				f.set_is_short
			end;
			if is_one_class_only then
				f.set_current_class_only
			end;
			if is_clickable then
				f.set_in_bench_mode
			end;
			if ordered_same_as_text then
				f.set_order_same_as_text
			end;
			f.execute;
			text := f.text;
			error := f.execution_error
		end;

end -- class CLASS_TEXT_FORMATTER
