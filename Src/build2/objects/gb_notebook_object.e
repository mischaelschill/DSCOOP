indexing
	description: "Objects that represent EiffelVision2 notebooks"
	date: "$Date$"
	revision: "$Revision$"

class
	GB_NOTEBOOK_OBJECT
	
inherit
	GB_WIDGET_LIST_OBJECT
		redefine
			add_child_object, remove_child, object
		end

create
	make_with_type,
	make_with_type_and_object
	
feature -- Access

	object: EV_NOTEBOOK
			-- Vision2 object referenced by `Current'.
			-- This is used in the display window.

feature -- Element change

	add_child_object (an_object: GB_OBJECT; position: INTEGER) is
			-- Add `an_object' to `Current' at position `position'.
		local
			counter: INTEGER
			context: GB_CONSTANT_CONTEXT
			original_key: STRING
			pixmap_paths: HASH_TABLE [STRING, INTEGER]
		do
			-- Must perform special handling of item text constants,
			-- as each one is referenced by an offset into the notebook.
			-- If we add a new child, this may affect the constants used.
			if position <= children.count then
				pixmap_paths := object.pixmap_paths
				from				
					counter := children.count + 1
				until
					counter = position
				loop
					counter := counter - 1	
					original_key := type + item_text + counter.out
					context := constants.item (original_key)
						-- Context may be Void if item does not use a constant value.
					if context /= Void then
						context.modify (context.constant, context.object, context.property, item_text + (counter + 1).out)
						constants.remove (original_key)
						constants.put (context, type + item_text + (counter + 1).out)
					end
					
						-- Now handle pixmap constants.
					original_key := type + Item_pixmap_string + counter.out
					context := constants.item (original_key)
						-- Context may be Void if item does not use a constant value.
					if context /= Void then
						context.modify (context.constant, context.object, context.property, Item_pixmap_string + (counter + 1).out)
						constants.remove (original_key)
						constants.put (context, type + Item_pixmap_string + (counter + 1).out)
					end
					
					if pixmap_paths.item (counter) /= Void then
						pixmap_paths.put (pixmap_paths.item (counter), counter + 1)
						pixmap_paths.remove (counter)
					end
				end
			end
			Precursor {GB_WIDGET_LIST_OBJECT} (an_object, position)
		end
		
	remove_child (an_object: GB_OBJECT) is
			-- Removed `an_object' and all its representations from `Current'.
		local
			position: INTEGER
			counter: INTEGER
			original_key: STRING
			context: GB_CONSTANT_CONTEXT
			pixmap_paths: HASH_TABLE [STRING, INTEGER]
		do
			position := children.index_of (an_object, 1)
			
			original_key := type + item_text + position.out
			constants.remove (original_key)
			if position < children.count then
				pixmap_paths := object.pixmap_paths
					-- We must update all items greater than the one removed so that if they
					-- use constants, their contexts are updated accordingly. This is because
					-- constants with notebook items use the index of the item as a look up
					-- for their context.
				from
					counter := position + 1
				until
					counter > children.count
				loop
					original_key := type + item_text + counter.out
					context := constants.item (original_key)
						-- Context may be Void if item does not use a constant value.
					if context /= Void then
						context.modify (context.constant, context.object, context.property, item_text + (counter - 1).out)
						constants.remove (original_key)
						constants.put (context, type + item_text + (counter - 1).out)
					end
					
					original_key := type + Item_pixmap_string + counter.out
					context := constants.item (original_key)
						-- Context may be Void if item does not use a constant value.
					if context /= Void then
						context.modify (context.constant, context.object, context.property, Item_pixmap_string + (counter - 1).out)
						constants.remove (original_key)
						constants.put (context, type + Item_pixmap_string + (counter - 1).out)
					end
					
					if pixmap_paths.item (counter) /= Void then
						pixmap_paths.put (pixmap_paths.item (counter), counter - 1)
						pixmap_paths.remove (counter)
					end
					counter := counter + 1
				end
			end
			Precursor {GB_WIDGET_LIST_OBJECT} (an_object)
		end
		
feature {NONE} -- Implementation

	item_text: STRING is "Item_text"
		-- Constant used for referncing item texts in XML.

end -- class GB_NOTEBOOK_OBJECT
