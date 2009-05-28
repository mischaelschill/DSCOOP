note
	description: "[
		A {XP_TAG_ELEMENT} is generated by parsing a "xeb"-file. {XP_TAG_ELEMENT}s
		are combined to trees.
	]"
	date: "$Date$"
	revision: "$Revision$"

class
	XP_TAG_ELEMENT

inherit
	XU_STRING_MANIPULATION

create
	make, make_empty

feature -- Initialization

	make (a_namespace: STRING; a_id: STRING; a_class_name: STRING; a_debug_information: STRING)
			-- `a_namespace': The namespace of the the tag
			-- `a_id': The id of the the tag
			-- `a_debug_information': Debug information for the backtrack to the original file
			-- `a_class_name': The name of the corresponding TAG-class
		require
			a_namespace_attached: a_namespace /= Void
			a_id_attached: a_id /= Void
			a_class_name_attached: a_class_name /= Void
			a_debug_information_attached: a_debug_information /= Void
			a_id_valid: not a_id.is_empty
			a_class_name_is_valid: not a_class_name.is_empty
		do
			namespace := a_namespace
			class_name := a_class_name
			id := a_id
			controller_id := ""
			create {ARRAYED_LIST [XP_TAG_ELEMENT]} children.make (3)
			create {HASH_TABLE [XP_TAG_ARGUMENT, STRING]} parameters.make (3)
			debug_information := a_debug_information
		end

	make_empty
		do
			make ("namespace", "id", "class_name", "debug_info")
		end

feature -- Access

	parameters: HASH_TABLE [XP_TAG_ARGUMENT, STRING]
			-- The parameters of the tag [value, parameter id]

	class_name: STRING
			-- The name of the corresponding {XTAG_TAG_SERIALIZER}-class

	debug_information: STRING
			-- Debug information (row and column in the xeb file)

	controller_id: STRING assign set_controller_id
			-- The id of the controller which should be used

	set_controller_id (a_id: STRING)
		require
			a_id_attached: a_id /= Void
		do
			controller_id := a_id
		end

	retrieve_value (a_id: STRING): XP_TAG_ARGUMENT
			-- Retrieves the value of the parameter with the the id `a_id'
		require
			a_id_attached: a_id /= Void
		do
			Result := parameters [a_id]
		ensure
			attached_result: attached Result
		end

	children: LIST [XP_TAG_ELEMENT]
			-- All the children of the tag

	id: STRING
			-- The tag id

	date: INTEGER assign set_date
			-- The timestamp of the corresponding file

	set_date (a_date: INTEGER)
			-- Sets the date.
		do
			date := a_date
		end

	namespace: STRING
			-- The namespace (tag library) of the tag

	has_children: BOOLEAN
			-- Are there any children?
		do
			Result := not children.is_empty
		end

	has_attribute (a_name: STRING): BOOLEAN
			-- Does the tag already have an attribute with the id `name'
		require
			a_name_attached: a_name /= Void
		do
			Result := parameters.has_key (a_name)
		end

feature --Basic Implementation

	put_subtag (a_child: XP_TAG_ELEMENT)
			-- Adds a tag to the list of children.
		require
			a_child_attached: a_child /= Void
		do
			children.extend (a_child)
		ensure
			child_has_been_added: old children.count + 1 = children.count
		end

	put_attribute (a_local_part: STRING; a_value: XP_TAG_ARGUMENT)
			-- Sets the attribute of this tag.
		require
			a_local_part_attached: a_local_part /= Void
			local_part_is_not_empty: not a_local_part.is_empty
		do
			parameters.extend (a_value, a_local_part)
		ensure
			attribute_has_been_added: old parameters.count + 1 = parameters.count
		end

	build_tag_tree (
				a_feature: XEL_FEATURE_ELEMENT;
				root_template: XGEN_SERVLET_GENERATOR_GENERATOR)
			-- Adds the needed expressions which build the tree of Current with the correct classes
		require
			a_feature_valid: attached a_feature
			root_template_valid: attached root_template
		do
			internal_build_tag_tree (a_feature, root_template, True)
		end

	set_parameters (a_parameters: HASH_TABLE [XP_TAG_ARGUMENT, STRING])
			-- Sets the parameters
		require
			a_parameters_valid: a_parameters /= Void
		do
			parameters := a_parameters
		end

	set_children (a_children: LIST [XP_TAG_ELEMENT])
			-- Sets the children
		do
			children := a_children
		end

	set_child (a_child: XP_TAG_ELEMENT)
			-- Empties the children list and adds `a_child' as unique child
		do
			create {ARRAYED_LIST [XP_TAG_ELEMENT]} children.make (1)
			children.extend (a_child)
		ensure
			not_more_than_one_child: children.count = 1
		end

	copy_tag_tree: XP_TAG_ELEMENT
			-- Copies the tag and its children
		do
			Result := copy_self
			from
				parameters.start
			until
				parameters.after
			loop
				Result.put_attribute (parameters.key_for_iteration, parameters.item_for_iteration)
				parameters.forth
			end

			from
				children.start
			until
				children.after
			loop
				Result.put_subtag (children.item.copy_tag_tree)
				children.forth
			end
		ensure
			attached_result: attached Result
		end

	copy_self: XP_TAG_ELEMENT
		do
			create Result.make (namespace, id, class_name, debug_information)
		ensure
			attached_result: attached Result
		end

	accept (a_visitor: XP_TAG_ELEMENT_VISITOR)
			-- Element part of the Visitor Pattern
		require
			visitor_attached: a_visitor /= Void
		do
			a_visitor.visit_tag_element (Current)
			accept_children (a_visitor)
		end

	accept_children (a_visitor: XP_TAG_ELEMENT_VISITOR)
		require
			a_visitor_attached: a_visitor /= Void
		local
			i: INTEGER
		do
				-- i is used as a iteration variable, so the list can be used concurrently
			from
				i := 1
			until
				i > children.count
			loop
				children[i].accept (a_visitor)
				i := i + 1
			end
		end

	resolve_all_dependencies (a_templates: HASH_TABLE [XP_TEMPLATE, STRING]; a_pending: LIST [PROCEDURE [ANY, TUPLE [a_uid: STRING; a_controller_class: STRING]]]; a_servlet_gen: XGEN_SERVLET_GENERATOR_GENERATOR)
			-- Resolves all the dependencies via include
		require
			a_templates_attached: a_templates /= Void
			a_pending_attached: a_pending /= Void
			a_servlet_gen_attached: a_servlet_gen /= Void
		do
			from
				children.start
			until
				children.after
			loop
				children.item.resolve_all_dependencies (a_templates, a_pending, a_servlet_gen)
				if children.item.date > date then
					date := children.item.date
				end
				children.forth
			end
		end

feature {XP_TAG_ELEMENT} -- Implementation

	internal_build_tag_tree (
					a_feature: XEL_FEATURE_ELEMENT;
					root_template: XGEN_SERVLET_GENERATOR_GENERATOR;
					is_root: BOOLEAN)
				-- Adds the needed expressions which build the tree of Current with the correct classes
		require
			root_template_attached: root_template /= Void
			a_feature_attached: a_feature /= Void
		do
			a_feature.append_comment (debug_information)
			a_feature.append_expression ("create {" + class_name + "} temp.make")
			a_feature.append_expression ("temp.debug_information := %"" + debug_information + "%"" )
			if is_root then
				a_feature.append_expression ("root_tag := temp")
			else
				a_feature.append_expression ("stack.item.add_to_body (temp)")
			end
			build_attributes (a_feature, parameters)
			if attached controller_id then
				a_feature.append_expression ("temp.current_controller_id := %"" + controller_id + "%"")
			end
			a_feature.append_expression ("temp.tag_id := %"" + id + "%"")

			if has_children then
				a_feature.append_expression ("stack.put (temp)")
				from
					children.start
				until
					children.after
				loop
					children.item.internal_build_tag_tree (a_feature, root_template, False)
					children.forth
				end
				a_feature.append_expression ("stack.remove")
			end
		end

	build_attributes (a_feature: XEL_FEATURE_ELEMENT; a_attributes: HASH_TABLE [XP_TAG_ARGUMENT, STRING])
			-- Adds expressions which put the right attributes to the tags
		require
			a_feature_attached: a_feature /= Void
			attributes_attached: a_attributes /= Void
		do
			from
				a_attributes.start
			until
				a_attributes.after
			loop
				a_feature.append_expression ("temp.put_attribute(%""
						+ a_attributes.key_for_iteration + "%", "
						+ "%"" + escape_string(a_attributes.item_for_iteration.value (controller_id)) + "%")"
					)
				a_attributes.forth
			end
		end

invariant
	controller_id_attached: controller_id /= Void
	debug_information_attached: debug_information /= Void
	class_name_attached: class_name /= Void
	parameters_attached: parameters /= Void
note
	copyright: "Copyright (c) 1984-2009, Eiffel Software"
	license: "GPL version 2 (see http://www.eiffel.com/licensing/gpl.txt)"
	licensing_options: "http://www.eiffel.com/licensing"
	copying: "[
			This file is part of Eiffel Software's Eiffel Development Environment.
			
			Eiffel Software's Eiffel Development Environment is free
			software; you can redistribute it and/or modify it under
			the terms of the GNU General Public License as published
			by the Free Software Foundation, version 2 of the License
			(available at the URL listed under "license" above).
			
			Eiffel Software's Eiffel Development Environment is
			distributed in the hope that it will be useful, but
			WITHOUT ANY WARRANTY; without even the implied warranty
			of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
			See the GNU General Public License for more details.
			
			You should have received a copy of the GNU General Public
			License along with Eiffel Software's Eiffel Development
			Environment; if not, write to the Free Software Foundation,
			Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
		]"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"
end
