-- Error when all unique constants involved in an inspect 
-- instruction don't have the same origin class

class VOMB6 

inherit

	VOMB
		redefine
			subcode, build_explain
		end;

feature

	subcode: INTEGER is 6;

feature

	unique_feature: FEATURE_I;
			-- Unique feature name

	set_unique_feature (f: FEATURE_I) is
			-- Assign `s' to `unique_name'.
		do
			unique_feature := f;
		end;

	written_class: CLASS_C;
			-- Class involved

	set_written_class (c: CLASS_C) is
			-- Assign `c' to `written_class'.
		do
			written_class := c;
		end;

	build_explain (ow: OUTPUT_WINDOW) is
		local
			wclass: CLASS_C
		do
			wclass := unique_feature.written_class;
			ow.put_string ("Constant: ");
			unique_feature.append_name (ow, wclass);
			ow.put_string (" From: ");
			wclass.append_name (ow);
			ow.put_string ("%NOrigin of conflicting constants: ");
			written_class.append_name (ow);
			ow.new_line;
		end;

end
