indexing
	description: "Objects that manipulate XML for saving/loading and possibly other%
		%internal uses."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	GB_XML_HANDLER

inherit
	
	INTERNAL
		export
			{NONE} all
		end
	
	GB_CONSTANTS
		export
			{NONE} all
		end
		
	GB_FILE_CONSTANTS
		export
			{NONE} all
		end
	
	GB_XML_UTILITIES
		export
			{NONE} all
		end
	
	GB_SHARED_TOOLS
		export
			{NONE} all
		end
		
	EV_DIALOG_CONSTANTS
		export
			{NONE} all
		end
		
	GB_SHARED_STATUS_BAR
		export
			{NONE} all
		end
		
	GB_SHARED_SYSTEM_STATUS
		export
			{NONE} all
		end
		
	GB_SHARED_CONSTANTS
		export
			{NONE} all
		end

feature -- Access

	components_loaded: BOOLEAN is
			-- Are components loaded?
		do
			Result := component_document /= Void
		end

feature -- Basic operations

	save is
			-- Save the currently built window to XML.
		local
			xml_store: GB_XML_STORE
		do
			create xml_store
			xml_store.register_object_written_agent (agent display_save_progress)
			xml_store.store
		end
		
	load is
			-- Retrieve the current built window from XML
		local
			xml_load: GB_XML_LOAD
		do
			system_status.set_object_structure_changing
			main_window.disable_menus
				-- During loading, menus must be disabled, as otherwise selections can be
				-- made during the load.
			create xml_load
			xml_load.load
			main_window.enable_menus
			system_status.set_object_structure_changed
		end
		
	import (file_name: STRING) is
			-- Import Build file `file_name'.
		require
			file_name_not_void: file_name /= Void
		local
			xml_load: GB_XML_IMPORT
		do
			create xml_load
			xml_load.import (file_name)
		end

	load_components is
			-- Load previously stored components in `component_document',
			-- or create `component_document' if no component file exists.
		local
			file: RAW_FILE
			an_element, component_element: XM_ELEMENT
			buffer: STRING
			parser: XM_EIFFEL_PARSER
		do
			check
				component_doc_void: component_document = Void
			end
			create file.make (component_filename)
			if file.exists then
					-- Load the existing file into `component document'
				create parser.make
				file.make_open_read (component_filename)
				create buffer.make (file.count)
				file.start
				file.read_stream (file.count)
				buffer := file.last_string
				parser.set_callbacks (pipe_callback.start)
				parser.parse_from_string (buffer)
				parser.finish_incremental
				component_document := pipe_callback.document
				an_element ?= component_document.first
				component_element ?= an_element.first
				
				component_selector.add_components (all_child_element_names (an_element))
			else
					-- Create `component_document'.
				create component_document.make_with_root_named ("Components", create {XM_NAMESPACE}.make_default)
				component_element := component_document.root_element
				add_attribute_to_element (component_element, "xsi", "xmlns", Schema_instance)
			end
		ensure
			component_doc_not_void: component_document /= Void
		end

	add_new_component (an_object: GB_OBJECT; component_name: STRING) is
			-- Add a new component based on `an_object', named `component_name'
			-- to `component_document'.
		require
			object_not_void: an_object /= Void
			name_ok: component_name /= Void and not component_name.is_empty
		local
			xml_store: GB_XML_STORE
			first_element: XM_ELEMENT
			component_element: XM_ELEMENT
			new_element: XM_ELEMENT
		do
			create xml_store
			first_element ?= component_document.first
			component_element := new_child_element (first_element, component_name, "Component")
			new_element := create_widget_instance (component_element, an_object.type)
			xml_store.add_new_object_to_output (an_object, new_element, create {GB_GENERATION_SETTINGS})
			Constants.flatten_constants (component_element)
		end

	save_components is
			-- Store `component_document' into file
			-- `component_filename'.
		local
			file: RAW_FILE
			error_dialog: GB_TWO_BUTTON_ERROR_DIALOG
			cancelled: BOOLEAN
		do
			check
				component_doc_not_void: component_document /= Void
			end
			create file.make (component_filename)
			from
			until
				file.is_writable or cancelled
			loop
				create error_dialog.make_with_text ("Unable to write to file : " + component_filename + ".%NPlease check file permissions and try again.")
				error_dialog.show_modal_to_window (main_window)
				if error_dialog.selected_button.is_equal (ev_abort) then
					cancelled := True
				end
			end
			if not cancelled then
				actual_save_components	
			end
		end
		
	actual_save_components is
			-- Actually perform saving of components.
		local
			file: KL_TEXT_OUTPUT_FILE
			formater: XM_FORMATTER
		do
			create file.make (component_filename)			
			file.open_write
			file.put_string (xml_format)
			create formater.make
			formater.set_output (file)
			formater.process_document (component_document)
			file.close
		end
		
	remove_component (component_name: STRING) is
			-- Removed component named `name' from `component_document'.
		require
			vaid_component_name: component_name /= Void and not component_name.is_empty
		local
			an_element: XM_ELEMENT
			element_to_remove: XM_ELEMENT
		do
			an_element ?= component_document.first
			element_to_remove := child_element_by_name (an_element, component_name)
			an_element.delete (element_to_remove)
		end

feature {GB_COMPONENT_SELECTOR_ITEM, GB_COMPONENT, GB_OBJECT} -- Implementation

	xml_element_representing_named_component (a_name: STRING): XM_ELEMENT is
			-- `Result' is the element representing component `a_name' in
			-- `component_document'.
		local
			an_element: XM_ELEMENT
		do
			an_element ?= component_document.first
			Result := child_element_by_name (an_element, a_name)
		ensure
			result_not_void: Result /= Void
		end
		
	component_root_element_type (a_name: STRING): STRING is
			-- `Result' is the type of object representing the root element
			-- of the component. i.e. "EV_BUTTON".
		local
			an_element: XM_ELEMENT
			component_element: XM_ELEMENT
			internal_element: XM_ELEMENT
			current_name: STRING
		do
			an_element ?= component_document.first
			component_element := child_element_by_name (an_element, a_name)
			from
				component_element.start
			until
				component_element.off or Result /= Void
			loop
				internal_element ?= component_element.item_for_iteration
				current_name := internal_element.name
				if current_name.is_equal (Item_string) then
					Result := internal_element.attribute_by_name (type_string).value
				end
				component_element.forth
			end
		ensure
			Result_not_void: Result /= Void
		end
		
		
feature {NONE} -- Implementation

	component_filename: FILE_NAME is
			-- Location of component file.
		do
			if visual_studio_information.is_visual_studio_wizard then
				create Result.make_from_string (visual_studio_information.wizard_installation_path)
				Result.extend ("components")
				Result.extend ("components.xml")
			else
				create Result.make_from_string ((create {EIFFEL_ENV}).Eiffel_installation_dir_name)
				Result.extend ("build")
				Result.extend ("components")
				Result.extend ("components.xml")
			end
		ensure
			Result_exists: Result /= Void and not Result.is_empty
		end
		
	display_save_progress (total, written: INTEGER) is
			-- Display current save progress as percentage of `total' based on `written',
			-- unless Build is running in Wizard mode.
		do
				-- The wizard version of Build has to perform a real store at the end,
				-- so we avoid displaying the output if we are in wizard mode.
			if not System_status.is_wizard_system then
				set_status_text ("Saving : " + (((written / total) * 95).truncated_to_integer.out) + "%%")
				environment.application.process_events
			end
		end
		
	pipe_callback: XM_TREE_CALLBACKS_PIPE is
			-- Create unique callback pipe.
		once
			create Result.make
		end

	component_document: XM_DOCUMENT
		-- Document which contains representations of all components
		-- that have been defined by the user.

end -- class GB_XML_HANDLER
