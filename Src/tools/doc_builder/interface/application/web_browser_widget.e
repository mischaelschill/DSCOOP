note
	description: "Objects that represent an EV_TITLED_WINDOW.%
		%The original version of this class was generated by EiffelBuild."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	WEB_BROWSER_WIDGET

inherit
	WEB_BROWSER_WIDGET_IMP
	
	TEXT_OBSERVER
		undefine
			copy,
			is_equal,
			default_create
		redefine
			on_text_fully_loaded
		end
		
	SHARED_OBJECTS
		undefine
			copy,
			default_create,
			is_equal
		end

create
	make
	
feature -- Creation

	make 
			-- Make
		do
			default_create
		end

feature {NONE} -- Initialization

	user_initialization
			-- called by `initialize'.
			-- Any custom user initialization that
			-- could not be performed in `initialize',
			-- (due to regeneration of implementation class)
			-- can be added here.	
		do			
				-- Browser
			create browser_winform_container
			browser_winform_container.extend (Internal_browser)
			browser_container.extend (browser_winform_container)
		end

feature -- Commands

	load_url (a_url: STRING)
			-- Load `a_url'
		local
			l_ptr: SYSTEM_OBJECT
		do			
			Internal_browser.navigate (a_url, $l_ptr, $l_ptr, $l_ptr, $l_ptr)			
		end		
	
	refresh
			-- Reload the HTML based upon changes made to `document'.  If there is no
			-- document then simply refresh the loaded url.
		do
			if document /= Void then				
				shared_document_manager.save_document
				load_url (generated_document)
			else
				Internal_browser.refresh
			end			
		end			
	
feature -- Status Setting

	set_document (a_doc: DOCUMENT)
			-- Set `document'
		require
			doc_not_void: a_doc /= Void
		local			
			l_util: UTILITY_FUNCTIONS
			l_name: STRING
		do
			document := a_doc
			create l_util
			l_name := document.name
			l_name.replace_substring_all ("\", "/")
			if l_util.file_type (l_name).is_equal ("xml") or l_util.file_type (l_name).is_equal ("html") then							
				load_url (generated_document)
			end
		ensure
			is_set: document = a_doc
		end
	
feature {NONE} -- Implementation	

	browser_winform_container: EV_WINFORM_CONTAINER
		-- Vision 2 Winforms container	

	internal_browser: AX_WEB_BROWSER
			-- Web browser control
		once
			create Result.make
		end

	document: DOCUMENT
			-- Document	

	generated_document: STRING
			-- Generated `document' content
		local
			l_generator: HTML_GENERATOR
			l_util: UTILITY_FUNCTIONS
		do
			create Result.make_empty
			if document.is_persisted then
				create l_generator			
				create l_util
				l_generator.generate_file (document, create {DIRECTORY}.make (l_util.temporary_html_location (document.name, False)))
				Result.append (l_generator.last_generated_file.name.string)
				Result.replace_substring_all ("\", "/")
			end			
		ensure
			has_result: Result /= Void
		end		

	on_text_fully_loaded
			-- Update `Current' when the text has been completely loaded.
			-- Observer must be registered as "edition_observer" for this feature to be called.
		local
			l_consts: SHARED_OBJECTS
		do
			create l_consts
			if  l_consts.shared_document_manager.current_document /= Void then
				set_document (l_consts.shared_document_manager.current_document)
			end
		end

note
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
end -- class WEB_BROWSER_WIDGET

