note

	description: "Area which arranges children in rows or columns"
	legal: "See notice at end of class.";
	status: "See notice at end of class.";
	date: "$Date$";
	revision: "$Revision$"

class

	ROW_COLUMN

inherit

	MANAGER
		redefine
			implementation
		end

create

	make, make_unmanaged

feature {NONE} -- Initialization

	make (a_name: STRING; a_parent: COMPOSITE)
			-- Create a row column with `a_name' as identifier,
			-- `a_parent' as parent and call `set_default'.
		require
			valid_name: a_name /= Void;
			valid_parent: a_parent /= Void
		do
			create_ev_widget (a_name, a_parent, True)
		ensure
			parent_set: parent = a_parent;
			identifier_set: identifier.is_equal (a_name);
			managed: managed
			--default_row_layout: not is_row_layout
		end;

	make_unmanaged (a_name: STRING; a_parent: COMPOSITE)
			-- Create an unmanaged row column with `a_name' as identifier,
			-- `a_parent' as parent and call `set_default'.
		require
			valid_name: a_name /= Void;
			valid_parent: a_parent /= Void
		do
			create_ev_widget (a_name, a_parent, False)
		ensure
			parent_set: parent = a_parent;
			identifier_set: identifier.is_equal (a_name);
			not_managed: not managed
			--default_row_layout: not is_row_layout
		end;

	create_ev_widget (a_name: STRING; a_parent: COMPOSITE; man: BOOLEAN)
			-- Create a row column with `a_name' as identifier,
			-- `a_parent' as parent and call `set_default'.
		do
			depth := a_parent.depth+1;
			widget_manager.new (Current, a_parent);
			if a_name /= Void then
				identifier := a_name.twin
			else
				identifier := Void
			end
			create {ROW_COLUMN_IMP} implementation.make (Current, man, a_parent);
			implementation.set_widget_default;
			set_default
		end;

feature -- Status report

	is_row_layout: BOOLEAN
			-- Are children laid out in rows?
		require
			exists: not destroyed
		do
			Result := implementation.is_row_layout
		end;

feature -- Status setting

	set_preferred_count (a_number: INTEGER)
			-- Set number of columns if column
			-- layout, or number of rows if row
			-- layout.
		require
			exists: not destroyed;
			Not_negative_number: a_number >= 0;
			Not_nul_number: not (a_number = 0)
		do
			implementation.set_preferred_count (a_number)
		end;

	set_row_layout
			-- Lay the children out in rows.
		require
			exists: not destroyed
		do
			implementation.set_row_layout (True)
		ensure
			Row_layout: is_row_layout
		end;

	set_column_layout
			-- Lay the children out in columns.
		require
			exists: not destroyed
		do
			implementation.set_row_layout (False)
		ensure
			Column_layout: not is_row_layout
		end;

	set_free_size
			-- Set size of items to be free, in vertical layout mode
			-- only width is set to be the same as the widest one, in
			-- horizontal layout mode only height is set to be the same
			-- as the tallest one.
		require
			exists: not destroyed
		do
			implementation.set_free_size
		end;

	set_same_size
			-- Set width of items to be the same as the widest one
			-- and height as the tallest one.
		require
			exists: not destroyed
		do
			implementation.set_same_size
		end;

feature -- Measurement

	margin_height: INTEGER
			-- Amount of blank space between the top edge
			-- of row column and the first item in each column, and the
			-- bottom edge of row column and the last item in each column
		require
			exists: not destroyed
		do
			Result:= implementation.margin_height
		ensure
			Result >= 0
		end;

	margin_width: INTEGER
			-- Amount of blank space between the left edge
			-- of row column and the first item in each row , and the
			-- right edge of row column and the last item in each row
		require
			exists: not destroyed
		do
			Result:= implementation.margin_width
		ensure
			Result >= 0
		end;

	spacing: INTEGER
			-- Spacing between items
		require
			exists: not destroyed
		do
			Result:= implementation.spacing
		ensure
			Greater_that_zero: Result >= 0
		end

feature -- Resizing

	set_margin_height (new_margin_height: INTEGER)
			-- Set amount of blank space between the top edge
			-- of row column and the first item in each column, and the
			-- bottom edge of row column and the last item in each column.
		require
			exists: not destroyed;
			not_negative_margin_height: new_margin_height >= 0
		do
			implementation.set_margin_height (new_margin_height)
		ensure
			margin_height = new_margin_height
		end;

	set_margin_width (new_margin_width: INTEGER)
			-- Set amount of blank space between the left edge
			-- of row column and the first item in each row , and the
			-- right edge of row column and the last item in each row.
		require
			exists: not destroyed;
			not_negative_margin_width: new_margin_width >= 0
		do
			implementation.set_margin_width (new_margin_width)
		ensure
			margin_width = new_margin_width
		end;

	set_spacing (new_spacing: INTEGER)
			-- Set spacing between items to `new_spacing'.
		require
			exists: not destroyed;
			Not_spacing_negative: new_spacing >= 0
		do
			implementation.set_spacing (new_spacing)
		ensure
			Spacing_set: spacing = new_spacing
		end;

feature {G_ANY, G_ANY_I, WIDGET_I, TOOLKIT} -- Implementation

	implementation: ROW_COLUMN_I;
			-- Implementation of row column

feature {NONE} -- Implementation

	set_default
			-- Set default values to current row column.
		do
		end;

note
	copyright:	"Copyright (c) 1984-2006, Eiffel Software and others"
	license:	"Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			 Eiffel Software
			 356 Storke Road, Goleta, CA 93117 USA
			 Telephone 805-685-1006, Fax 805-685-6869
			 Website http://www.eiffel.com
			 Customer support http://support.eiffel.com
		]"




end -- class ROW_COLUMN

