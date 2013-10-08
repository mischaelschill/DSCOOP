note
	description: "An ESCHER extension to ABEL. Adds a version attribute to inserted objects, and checks on this version during retrieval."
	author: "Roman Schmocker"
	date: "$Date$"
	revision: "$Revision$"

class
	PS_VERSION_HANDLER

inherit

	PS_BACKEND_COMPATIBILITY
		redefine
			key_mapper
		end

inherit {NONE}

	REFACTORING_HELPER

create
	make

feature {NONE} -- Initialization

	make (real: PS_BACKEND_COMPATIBILITY; schema_evolution_handlers: HASH_TABLE[SCHEMA_EVOLUTION_HANDLER,STRING])
			-- Initialization for `Current'.
		local
			factory: PS_METADATA_FACTORY
		do
			real_backend := real
			create factory.make
			integer_metadata := factory.create_metadata_from_type ({INTEGER})

			schema_evolution_handlers_table := schema_evolution_handlers
		end

	real_backend: PS_BACKEND_COMPATIBILITY
			-- The actual backend used for storage

	integer_metadata: PS_TYPE_METADATA
			-- Metadata for INTEGER

	schema_evolution_handlers_table: HASH_TABLE[SCHEMA_EVOLUTION_HANDLER,STRING]
			-- Hashtable with class names as keys and respective schema evolution handlers as values

feature {PS_EIFFELSTORE_EXPORT} -- Supported collection operations

	supports_object_collection: BOOLEAN
			-- Can the current backend handle relational collections?
		do
			Result := real_backend.supports_object_collection
		end

	supports_relational_collection: BOOLEAN
			-- Can the current backend handle relational collections?
		do
			Result := real_backend.supports_relational_collection
		end

feature {PS_EIFFELSTORE_EXPORT} -- Status report

	can_handle_relational_collection (owner_type, collection_item_type: PS_TYPE_METADATA): BOOLEAN
			-- Can the current backend handle the relational collection between the two classes `owner_type' and `collection_type'?
		do
			Result := real_backend.can_handle_relational_collection (owner_type, collection_item_type)
		end

	can_handle_object_oriented_collection (collection_type: PS_TYPE_METADATA): BOOLEAN
			-- Can the current backend handle an object_oriented collection of type `collection_type'?
		do
			Result := real_backend.can_handle_object_oriented_collection (collection_type)
		end

feature {PS_EIFFELSTORE_EXPORT} -- Object retrieval operations

	internal_retrieve (type: PS_TYPE_METADATA; criteria: PS_CRITERION; attributes: LIST [STRING]; transaction: PS_TRANSACTION): ITERATION_CURSOR [PS_RETRIEVED_OBJECT]
			-- Retrieves all objects of class `type' (direct instance - not inherited from) that match the criteria in `criteria' within transaction `transaction'.
			-- If `attributes' is not empty, it will only retrieve the attributes listed there.
			-- If an attribute was `Void' during an insert, or it doesn't exist in the database because of a version mismatch, the attribute value during retrieval will be an empty string and its class name `NONE'.
			-- If `type' has a generic parameter, the retrieve function will return objects of all generic instances of the generating class.
			-- You can find out about the actual generic parameter by comparing the class name associated to a foreign key value.
		local
			reflection: INTERNAL
			current_class_instance: ANY
			current_version, stored_version, no_of_attr, i: INTEGER
			result_list: LINKED_LIST [PS_RETRIEVED_OBJECT]
			stored_object: PS_RETRIEVED_OBJECT
			stored_obj_attr_values: HASH_TABLE [TUPLE [STRING, STRING], STRING]
			set: BOOLEAN
			current_class_name, attr_name, attr_type_as_string: STRING
			exception: EXCEPTIONS

			test_var: TUPLE[STRING,STRING]
				-- Used for testing purposes
		do
			create reflection
			current_class_instance := reflection.new_instance_of (type.type.type_id)
			if attached {VERSIONED_CLASS} current_class_instance as versioned_object then
				current_version := versioned_object.version
				check
					version_positive: current_version > 0
				end
					-- Collect the results
				from
					create result_list.make
					if attributes.is_empty then
						attributes.append (type.attributes)
					end
					attributes.extend ("version")
					Result := real_backend.retrieve (type, criteria, attributes, transaction)
				until
					Result.after
				loop

					-- Testing-related code start
					if simulate_version_mismatch then
						fixme ("Remove testing-related code")
						if simulate_added_attribute then
							-- 'current_version' has to be set to 2 such that 'v1_to_v2' from APPLICATION_SCHEMA_EVOLUTION_HANDLER is used
							current_version := 2
							-- Simulate that 'new_attr' is a new attribute in class ESCHER_TEST_CLASS_2
							Result.item.remove_attribute ("new_attr")
							Result.item.attributes.start
						end
						if simulate_attribute_type_changed then
							-- 'current_version' has to be set to 3 such that 'v2_to_v3' from APPLICATION_SCHEMA_EVOLUTION_HANDLER is used
							current_version := 3
							-- Simulate that 'type_changed' was previously of type INTEGER
							test_var := Result.item.attribute_value ("type_changed")
							Result.item.remove_attribute ("type_changed")
							Result.item.attributes.start
							if attached {STRING} test_var.item (1) as attr_value then
								Result.item.add_attribute ("type_changed", attr_value, "INTEGER_32")
							end
						end
						if simulate_attribute_name_changed then
							-- 'current_version' has to be set to 4 such that 'v3_to_v4' from APPLICATION_SCHEMA_EVOLUTION_HANDLER is used
							current_version := 4
							-- Simulate that 'name_changed' was previously named 'old_name'
							test_var := Result.item.attribute_value ("name_changed")
							Result.item.remove_attribute ("name_changed")
							Result.item.attributes.start
							if attached {STRING} test_var.item (1) as attr_value then
								if attached {STRING} test_var.item (2) as attr_type then
									Result.item.add_attribute ("old_name", attr_value, attr_type)
								end
							end
						end
						if simulate_removed_attribute then
							-- 'current_version' has to be set to 6 such that no conversion function is used ('v5_to_v6' not available in APPLICATION_SCHEMA_EVOLUTION_HANDLER)
							current_version := 6
							-- Simulate that 'removed_attr' was removed from class ESCHER_TEST_CLASS_2
							Result.item.add_attribute ("removed_attr", "12", "INTEGER_32")
						end
						if simulate_multiple_changes then
							-- 'current_version' has to be set to 5 such that 'v4_to_v5' from APPLICATION_SCHEMA_EVOLUTION_HANDLER is used
							current_version := 5
						end
					end
					-- Testing-related code end

					result_list.extend (Result.item)
					Result.forth
				end

				current_class_name := reflection.class_name (current_class_instance)
				no_of_attr := reflection.field_count (current_class_instance)
				-- Check for each result if the version matches
				across
					result_list as cursor
				loop
					stored_object := cursor.item
					stored_version := stored_object.attribute_value ("version").value.to_integer
					if stored_version /= current_version then
						-- Save all attribute values in 'stored_obj_attr_values'
						-- This values could be needed to calculate functions returned by the schema evolution handler
						stored_obj_attr_values := get_attribute_values(stored_object)
						clean_stored_obj(stored_object)
						if attached {SCHEMA_EVOLUTION_HANDLER} schema_evolution_handlers_table.item (current_class_name) as current_schema_evolution_handler then
							-- Create a fresh instance of the current class
							current_class_instance := reflection.new_instance_of (type.type.type_id)
							-- Go through every attribute in 'current_class_instance'
							from i := 1 until i > no_of_attr loop
								set := false
								attr_name := reflection.field_name (i, current_class_instance)
								-- Try to use schema evolution handler to calculate value of attribute
								set := handle_object_evolution (current_schema_evolution_handler, current_class_instance, stored_obj_attr_values, reflection.field_type (i, current_class_instance), attr_name, i, stored_version, current_version)
								if set then
									-- Attribute was set in current_class_instance by the schema evolution handler
									if attached {ANY} reflection.field (i, current_class_instance) as attr_value then
										attr_type_as_string := get_type_as_string (reflection.field_type (i, current_class_instance))
										stored_object.add_attribute (attr_name, attr_value.out, attr_type_as_string)
									end
								else
									-- Attribute wasn't set by the schema evolution handler
									if attached {TUPLE[STRING,STRING]} stored_obj_attr_values.item (attr_name) as tuple then
										if attached {STRING} tuple.item (1) as attr_value then
											if attached {STRING} tuple.item (2) as attr_type then
												stored_object.add_attribute (attr_name, attr_value, attr_type)
											end
										end
									end
								end
								i := i + 1
							end
						else
							create exception
							exception.raise ("No schema evolution handler available for class '" + current_class_name + "'.")
						end
					else
						cursor.item.remove_attribute ("version")
					end
				end -- loop
				Result := result_list.new_cursor
					-- Required because of postcondition...
				attributes.compare_objects
				attributes.prune ("version")
			else
				Result := real_backend.retrieve (type, criteria, attributes, transaction)
			end
		end

	internal_retrieve_from_keys (type: PS_TYPE_METADATA; primary_keys: LIST [INTEGER]; transaction: PS_TRANSACTION): LINKED_LIST [PS_RETRIEVED_OBJECT]
			-- Retrieve all objects of type `type' and with primary key in `primary_keys'.
		local
			reflection: INTERNAL
			type_instance: ANY
			res_cursor: ITERATION_CURSOR [PS_RETRIEVED_OBJECT]
		do
			create reflection
			type_instance := reflection.new_instance_of (type.type.type_id)
			if attached {VERSIONED_CLASS} type_instance as versioned_object then
					-- Use the retrieve function for checking
				from
					create Result.make
					res_cursor := real_backend.retrieve (type, create {PS_EMPTY_CRITERION}, create {LINKED_LIST [STRING]}.make, transaction)
				until
					res_cursor.after
				loop
					if primary_keys.has (res_cursor.item.primary_key) then
						Result.extend (res_cursor.item)
					end
					res_cursor.forth
				end
			else
				Result := real_backend.retrieve_from_keys (type, primary_keys, transaction)
			end
		end

feature {PS_EIFFELSTORE_EXPORT} -- Object write operations

	insert (an_object: PS_SINGLE_OBJECT_PART; a_transaction: PS_TRANSACTION)
			-- Inserts the object into the database
		local
			stored_version: INTEGER
			version_attribute: PS_BASIC_ATTRIBUTE_PART

			test_int_attribute: PS_BASIC_ATTRIBUTE_PART
		do
			if attached {VERSIONED_CLASS} an_object.represented_object as versioned_object then
				stored_version := versioned_object.version

				-- Testing-related code start
				if simulate_version_mismatch then
					fixme ("Remove testing-related code")
					stored_version := stored_version - 1
					if simulate_added_attribute then
						-- 'stored_version' has to be set to 1 such that 'v1_to_v2' from APPLICATION_SCHEMA_EVOLUTION_HANDLER is used
						stored_version := 1
					end
					if simulate_attribute_type_changed then
						-- 'stored_version' has to be set to 2 such that 'v2_to_v3' from APPLICATION_SCHEMA_EVOLUTION_HANDLER is used
						stored_version := 2
					end
					if simulate_attribute_name_changed then
						-- 'stored_version' has to be set to 3 such that 'v3_to_v4' from APPLICATION_SCHEMA_EVOLUTION_HANDLER is used
						stored_version := 3
					end
					if simulate_removed_attribute then
						-- 'stored_version' has to be set to 5 such that no conversion function is used ('v5_to_v6' not available in APPLICATION_SCHEMA_EVOLUTION_HANDLER)
						stored_version := 5
					end
					if simulate_multiple_changes then
						-- 'stored_version' has to be set to 4 such that that 'v4_to_v5' from APPLICATION_SCHEMA_EVOLUTION_HANDLER is used
						stored_version := 4
					end
				end
				-- Testing-related code end

				create version_attribute.make (stored_version, integer_metadata, an_object.root)
				an_object.add_attribute ("version", version_attribute)
				real_backend.insert (an_object, a_transaction)
				an_object.attributes.prune ("version") -- to satisfy postcondition
			else
				real_backend.insert (an_object, a_transaction)
			end
		end

	update (an_object: PS_SINGLE_OBJECT_PART; a_transaction: PS_TRANSACTION)
			-- Updates an_object
		do
			real_backend.update (an_object, a_transaction)
		end

	delete (an_object: PS_SINGLE_OBJECT_PART; a_transaction: PS_TRANSACTION)
			-- Deletes an_object from the database
		do
			real_backend.delete (an_object, a_transaction)
		end

feature {PS_EIFFELSTORE_EXPORT} -- Object-oriented collection operations

	retrieve_all_collections (collection_type: PS_TYPE_METADATA; transaction: PS_TRANSACTION): ITERATION_CURSOR [PS_RETRIEVED_OBJECT_COLLECTION]
			-- Retrieves all collections of type `collection_type'.
		do
			Result := real_backend.retrieve_all_collections (collection_type, transaction)
		end

	retrieve_object_oriented_collection (collection_type: PS_TYPE_METADATA; collection_primary_key: INTEGER; transaction: PS_TRANSACTION): PS_RETRIEVED_OBJECT_COLLECTION
			-- Retrieves the object-oriented collection of type `object_type' and with primary key `object_primary_key'.
		do
			Result := real_backend.retrieve_object_oriented_collection (collection_type, collection_primary_key, transaction)
		end

	insert_object_oriented_collection (a_collection: PS_OBJECT_COLLECTION_PART [ITERABLE [detachable ANY]]; a_transaction: PS_TRANSACTION)
			-- Add all entries in a_collection to the database. If the order is not conflicting with the items already in the database, it will try to preserve order.
		do
			real_backend.insert_object_oriented_collection (a_collection, a_transaction)
		end

	delete_object_oriented_collection (a_collection: PS_OBJECT_COLLECTION_PART [ITERABLE [detachable ANY]]; a_transaction: PS_TRANSACTION)
			-- Delete a_collection from the database
		do
			real_backend.delete_object_oriented_collection (a_collection, a_transaction)
		end

feature {PS_EIFFELSTORE_EXPORT} -- Relational collection operations

	retrieve_relational_collection (owner_type, collection_item_type: PS_TYPE_METADATA; owner_key: INTEGER; owner_attribute_name: STRING; transaction: PS_TRANSACTION): PS_RETRIEVED_RELATIONAL_COLLECTION
			-- Retrieves the relational collection between class `owner_type' and `collection_item_type', where the owner has primary key `owner_key' and the attribute name of the collection inside the owner object is called `owner_attribute_name'
		do
			Result := real_backend.retrieve_relational_collection (owner_type, collection_item_type, owner_key, owner_attribute_name, transaction)
		end

	insert_relational_collection (a_collection: PS_RELATIONAL_COLLECTION_PART [ITERABLE [detachable ANY]]; a_transaction: PS_TRANSACTION)
			-- Add all entries in a_collection to the database
		do
			real_backend.insert_relational_collection (a_collection, a_transaction)
		end

	delete_relational_collection (a_collection: PS_RELATIONAL_COLLECTION_PART [ITERABLE [detachable ANY]]; a_transaction: PS_TRANSACTION)
			-- Delete a_collection from the database
		do
			real_backend.delete_relational_collection (a_collection, a_transaction)
		end

feature {PS_EIFFELSTORE_EXPORT} -- Transaction handling

	commit (a_transaction: PS_TRANSACTION)
			-- Tries to commit `a_transaction'. As with every other error, a failed commit will result in a new exception and the error will be placed inside `a_transaction'
		do
			real_backend.commit (a_transaction)
		end

	rollback (a_transaction: PS_TRANSACTION)
			-- Aborts `a_transaction' and undoes all changes in the database
		do
			real_backend.rollback (a_transaction)
		end

	transaction_isolation_level: PS_TRANSACTION_ISOLATION_LEVEL
			-- The currently active transaction isolation level
		do
			Result := real_backend.transaction_isolation_level
		end

	set_transaction_isolation_level (a_level: PS_TRANSACTION_ISOLATION_LEVEL)
			-- Set the transaction isolation level `a_level' for all future transactions
		do
			real_backend.set_transaction_isolation_level (a_level)
		end

feature {PS_EIFFELSTORE_EXPORT} -- Mapping

	key_mapper: PS_KEY_POID_TABLE
			-- Maps POIDs to primary keys as used by this backend
		do
			Result := real_backend.key_mapper
		end

feature {NONE} -- Schema Evolution helper functions

	get_attribute_values (stored_obj: PS_RETRIEVED_OBJECT): HASH_TABLE [TUPLE [STRING, STRING], STRING]
			-- Fill hashtable with a tuple containing attribute value and class name of generating class for each attribute in 'stored_obj'
		local
			current_attr_name: STRING
		do
			create Result.make (10)
			from
				stored_obj.attributes.start
			until
				stored_obj.attributes.after
			loop
				current_attr_name := stored_obj.attributes.item
				Result.extend (stored_obj.attribute_value (current_attr_name), current_attr_name)
				stored_obj.attributes.forth
			end
		end

	clean_stored_obj (stored_obj: PS_RETRIEVED_OBJECT)
			-- Remove all attributes in 'stored_obj'
		local
			current_name: STRING
		do
			from
				stored_obj.attributes.start
			until
				stored_obj.attributes.after
			loop
				current_name := stored_obj.attributes.item
				stored_obj.remove_attribute (current_name)
			end
		end

	handle_object_evolution (current_schema_evolution_handler: SCHEMA_EVOLUTION_HANDLER; current_class_instance: ANY; stored_obj_attr_values: HASH_TABLE [TUPLE [STRING, STRING], STRING]; type: INTEGER; attr_name: STRING; index, stored_version, current_version: INTEGER): BOOLEAN
			-- Check whether conversion function for attribute 'attr_name' from 'stored_version' to 'current_version' is available
			-- In case a conversion function is available use feature 'evaluate_function' to evaluate the respective function
		local
			reflection: INTERNAL
		do
			create reflection
			Result := false
			-- Check wheter conversion function from 'stored_version' to 'current_version' is available in 'current_schema_evolution_handler'
			-- ATTENTION: feature 'conversion_function_available' is a new feature
			if current_schema_evolution_handler.conversion_function_available (current_version, stored_version) then
				-- If conversion function is available get it from the current schema evolution handler
				if attached {HASH_TABLE [TUPLE [LIST [STRING], FUNCTION [ANY, TUPLE [LIST [ANY]], ANY]], STRING]} current_schema_evolution_handler.create_schema_evolution_handler (current_version, stored_version) as tmp then
					if attached {TUPLE [LIST [STRING], FUNCTION [ANY, TUPLE [LIST [ANY]], ANY]]} tmp.item (attr_name) as tuple then
						evaluate_function(current_class_instance, stored_obj_attr_values, type, index, tuple)
						Result := true
					end
				end
			end
		end

	evaluate_function (current_class_instance: ANY; stored_obj_attr_values: HASH_TABLE [TUPLE [STRING, STRING], STRING]; type: INTEGER; index: INTEGER; tuple: TUPLE [LIST [STRING], FUNCTION [ANY, TUPLE [LIST [ANY]], ANY]])
			-- 'tuple' contains a list of variables and a function
			-- The list of variables contains the names of the variables that are needed to evaluate the function
			-- The values of the variables that are needed as input arguments to the function can be found in 'stored_obj_attr_values'
			-- The attribute with index 'index' and type 'type' inside 'current_class_instance' needs to be set to the result of the function
		local
			reflection: INTERNAL
			values: ARRAYED_LIST[ANY]
		do
			create reflection
			-- Get the list of variables
			if attached {LIST[STRING]} tuple.item (1) as vars then
				-- Get the function
				if attached {FUNCTION [ANY, TUPLE [LIST [ANY]], ANY]} tuple.item (2) as function then
					create values.make (vars.count)
					-- Calculate for each variable the respective value
					from vars.start until vars.after loop
						if attached {TUPLE[STRING,STRING]} stored_obj_attr_values.item (vars.item) as current_attr_tuple then
							if attached {STRING} current_attr_tuple.item (1) as current_value then
								if attached {STRING} current_attr_tuple.item (2) as current_type then
									values.force (convert_string(current_value,current_type))
								end
							end
						end
						vars.forth
					end
					set_attribute(index, type, current_class_instance, function.item ([values]))
				end
			end
		end

	set_attribute (index: INTEGER; type: INTEGER; obj: ANY; generic_value: ANY; )
			-- Set the attribute with index 'index' of type 'type' of object 'obj' to value 'generic_value'
		require
			value_exists: generic_value /= Void
			object_exists: obj /= Void
			positive_index: index > 0
		local
			reflection: INTERNAL
			exception: EXCEPTIONS
			value: STRING
		do
			create reflection
			value := generic_value.out
			-------------------------INTEGER-------------------------
			if type = reflection.integer_8_type and value.is_integer_8 then
				reflection.set_integer_8_field (index, obj, value.to_integer_8)

			elseif type = reflection.integer_16_type and value.is_integer_16 then
				reflection.set_integer_16_field (index, obj, value.to_integer_16)

			elseif type = reflection.integer_32_type and value.is_integer_32 then
				reflection.set_integer_32_field (index, obj, value.to_integer_32)

			elseif type = reflection.integer_64_type and value.is_integer_64 then
				reflection.set_integer_64_field (index, obj, value.to_integer_64)
			-------------------------DOUBLE-------------------------
			elseif type = reflection.double_type and value.is_double then
				reflection.set_double_field (index, obj, value.to_double)
			-------------------------CHAR-------------------------
			elseif type = reflection.character_8_type and value.count = 1 then
				reflection.set_character_8_field (index, obj, value.area[1])

			elseif type = reflection.character_32_type and value.count = 1 then
				reflection.set_character_32_field (index, obj, value.area[1])
			-------------------------BOOLEAN-------------------------
			elseif type = reflection.boolean_type and value.is_boolean then
				reflection.set_boolean_field (index, obj, value.to_boolean)
			-------------------------NATURAL-------------------------
			elseif type = reflection.natural_8_type and value.is_natural_8 then
				reflection.set_natural_8_field (index, obj, value.to_natural_8)

			elseif type = reflection.natural_16_type and value.is_natural_16 then
				reflection.set_natural_16_field (index, obj, value.to_natural_16)

			elseif type = reflection.natural_32_type and value.is_natural_32 then
				reflection.set_natural_32_field (index, obj, value.to_natural_32)

			elseif type = reflection.natural_64_type and value.is_natural_64 then
				reflection.set_natural_64_field (index, obj, value.to_natural_64)
			-------------------------REAL-------------------------
			elseif type = reflection.real_32_type and value.is_real then
				reflection.set_real_32_field (index, obj, value.to_real)
			-------------------------REF-------------------------
			elseif type = reflection.reference_type then
				reflection.set_reference_field (index, obj, generic_value)
			-------------------------ELSE-------------------------
			else
				create exception
				exception.raise ("The static and dynamic type of the attribute are incompatible.")
			end
		end

	convert_string (value, type: STRING): ANY
		-- Convert value 'value' to type 'type'
		-- The following types can be handled: INTEGER, DOUBLE, BOOLEAN, NATURAL, REAL and STRING
		-- TODO: Implement other possible types
		local
			exception: EXCEPTIONS
		do
			-------------------------INTEGER-------------------------
			if type.is_equal ("INTEGER_8") and value.is_integer_8 then
				Result := value.to_integer_8

			elseif type.is_equal ("INTEGER_16") and value.is_integer_16 then
				Result := value.to_integer_16

			elseif type.is_equal ("INTEGER_32") and value.is_integer_32 then
				Result := value.to_integer_32

			elseif type.is_equal ("INTEGER_64") and value.is_integer_64 then
				Result := value.to_integer_64
			-------------------------DOUBLE-------------------------
			elseif type.is_equal ("DOUBLE") and value.is_double then
				Result := value.to_double
			-------------------------BOOLEAN-------------------------
			elseif type.is_equal ("BOOLEAN") and value.is_boolean then
				Result := value.to_boolean
			-------------------------NATURAL-------------------------
			elseif type.is_equal ("NATURAL_8") and value.is_natural_8 then
				Result := value.to_natural_8

			elseif type.is_equal ("NATURAL_16") and value.is_natural_16 then
				Result := value.to_natural_16

			elseif type.is_equal ("NATURAL_32") and value.is_natural_32 then
				Result := value.to_natural_32

			elseif type.is_equal ("NATURAL_64") and value.is_natural_64 then
				Result := value.to_natural_64
			-------------------------REAL-------------------------
			elseif type.is_equal ("REAL_32") and value.is_real then
				Result := value.to_real_32

			elseif type.is_equal ("REAL_64") and value.is_real then
				Result := value.to_real_64
			-------------------------STRING-------------------------
			elseif type.is_equal ("STRING_8") then
				Result := value

			else
				Result := ""
				create exception
				exception.raise (type + " cannot be handled.")
			end
		end

	get_type_as_string (type: INTEGER): STRING
			-- Get type of 'type' as string
			-- The following types can be handled: INTEGER, DOUBLE, BOOLEAN, NATURAL, REAL and STRING
			-- ATTENTION: Reference type has to be STRING_8
			-- TODO: Implement other possible types
		local
			reflection: INTERNAL
			exception: EXCEPTIONS
			test_instance: ANY
		do
			create reflection
			-------------------------INTEGER-------------------------
			if type = reflection.integer_8_type then
				Result := "INTEGER_8"

			elseif type = reflection.integer_16_type then
				Result := "INTEGER_16"

			elseif type = reflection.integer_32_type then
				Result := "INTEGER_32"

			elseif type = reflection.integer_64_type then
				Result := "INTEGER_64"
			-------------------------DOUBLE-------------------------
			elseif type = reflection.double_type then
				Result := "DOUBLE"
			-------------------------BOOLEAN-------------------------
			elseif type = reflection.boolean_type then
				Result := "BOOLEAN"
			-------------------------NATURAL-------------------------
			elseif type = reflection.natural_8_type then
				Result := "NATURAL_8"

			elseif type = reflection.natural_16_type then
				Result := "NATURAL_16"

			elseif type = reflection.natural_32_type then
				Result := "NATURAL_32"

			elseif type = reflection.natural_64_type then
				Result := "NATURAL_64"
			-------------------------REAL-------------------------
			elseif type = reflection.real_32_type then
				Result := "REAL_32"

			elseif type = reflection.real_64_type then
				Result := "REAL_64"
			-------------------------REF-------------------------
			elseif type = reflection.reference_type then
				-- STRING has type id 1
				if type = 1 then
					Result := "STRING_8"
				else
					Result := ""
					create exception
					exception.raise ("Reference type with id '" + type.out + "' cannot be handled.")
				end
			-------------------------ELSE-------------------------
			else
				Result := ""
				create exception
				exception.raise ("Type with id '" + type.out + "' cannot be handled.")
			end
		end

feature {PS_EIFFELSTORE_EXPORT} -- Testing

	wipe_out
			-- Wipe out everything and initialize new.
		do
			real_backend.wipe_out
		end

feature -- Testing

	set_simulation (switch: BOOLEAN)
			-- Enable or disable the testing simulation
		do
			simulate_version_mismatch := switch
			fixme ("Remove testing-related code")
		end

	set_simulation_added_attribute (switch: BOOLEAN)
			-- Simulate added attribute
		do
			simulate_added_attribute := switch
			fixme ("Remove testing-related code")
		end

	set_simulation_attribute_type_changed (switch: BOOLEAN)
			-- Simulate changed attribute type
		do
			simulate_attribute_type_changed := switch
			fixme ("Remove testing-related code")
		end

	set_simulation_attribute_name_changed (switch: BOOLEAN)
			-- Simulate changed attribute name
		do
			simulate_attribute_name_changed := switch
			fixme ("Remove testing-related code")
		end

	set_simulation_removed_attribute (switch: BOOLEAN)
			-- Simulate removed attribute
		do
			simulate_removed_attribute := switch
			fixme ("Remove testing-related code")
		end

	set_simulation_multiple_changes (switch: BOOLEAN)
			-- Simulate multiple changes
		require
			simulate_added_attribute
			simulate_attribute_type_changed
			simulate_attribute_name_changed
			simulate_removed_attribute
		do
			simulate_multiple_changes := switch
			fixme ("Remove testing-related code")
		end

	simulate_version_mismatch: BOOLEAN
			-- Insert a wrong version on purpose for testing

	simulate_added_attribute: BOOLEAN
			-- Remove an attribute from an inserted ESCHER_TEST_CLASS_2 object on purpose for testing

	simulate_attribute_type_changed: BOOLEAN
			-- Change an attribute type from an inserted ESCHER_TEST_CLASS_2 object on purpose for testing

	simulate_attribute_name_changed: BOOLEAN
			-- Change an attribute name from an inserted ESCHER_TEST_CLASS_2 object on purpose for testing

	simulate_removed_attribute: BOOLEAN
			-- Add an attribute to an inserted ESCHER_TEST_CLASS_2 object on purpose for testing

	simulate_multiple_changes: BOOLEAN
			-- Simulate multiple changes on purpose for testing

end
