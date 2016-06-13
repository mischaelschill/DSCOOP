/*
	description: "C-Eiffel Call-In Library."
	date:		"$Date$"
	revision:	"$Revision$"
	copyright:	"Copyright (c) 1985-2016, Eiffel Software."
	license:	"GPL version 2 see http://www.eiffel.com/licensing/gpl.txt)"
	licensing_options:	"Commercial license is available at http://www.eiffel.com/licensing"
	copying: "[
			This file is part of Eiffel Software's Runtime.

			Eiffel Software's Runtime is free software; you can
			redistribute it and/or modify it under the terms of the
			GNU General Public License as published by the Free
			Software Foundation, version 2 of the License
			(available at the URL listed under "license" above).

			Eiffel Software's Runtime is distributed in the hope
			that it will be useful,	but WITHOUT ANY WARRANTY;
			without even the implied warranty of MERCHANTABILITY
			or FITNESS FOR A PARTICULAR PURPOSE.
			See the	GNU General Public License for more details.

			You should have received a copy of the GNU General Public
			License along with Eiffel Software's Runtime; if not,
			write to the Free Software Foundation, Inc.,
			51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA
		]"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"
*/

/*
doc:<file name="cecil.c" header="eif_cecil.h" version="$Id$" summary="C-Eiffel Call-In Library">
*/

#include "eif_portable.h"
#include "rt_malloc.h"
#include "eif_garcol.h"
#include "rt_cecil.h"
#include "eif_hector.h"
#include "rt_struct.h"
#include "rt_tools.h"
#include "eif_eiffel.h"				/* Need string header */
#include "rt_macros.h"
#include "rt_lmalloc.h"
#include "eif_project.h"
#include "rt_except.h"
#include "rt_threads.h"
#include "rt_gen_types.h"
#include "rt_assert.h"
#include <string.h>
#ifdef I_STDARG
#include <stdarg.h>
#else
#ifdef I_VARARGS
#include <varargs.h>
#endif
#endif
#include "rt_globals_access.h"

/*
doc:	<attribute name="eif_visible_is_off" return_type="char" export="public">
doc:		<summary>If set to True, we will not throw an exception if feature cannot be found or is not visible.</summary>
doc:		<access>Read/Write</access>
doc:		<thread_safety>Safe as access is done through `eif_cecil_mutex'.</thread_safety>
doc:		<synchronization>eif_cecil_mutex</synchronization>
doc:	</attribute>
*/
rt_public unsigned char eif_visible_is_off = (unsigned char) 1;

/*
doc:	<attribute name="eif_default_pointer" return_type="void *" export="private">
doc:		<summary>Return value when `eif_field_safe' fails.</summary>
doc:		<access>Read</access>
doc:		<thread_safety>Safe</thread_safety>
doc:	</attribute>
*/
rt_private void *eif_default_pointer = NULL;

/*
 * Cecil mutex in MT mode.
 */
#ifdef EIF_THREADS
/*
doc:	<attribute name="eif_cecil_mutex" return_type="EIF_CS_TYPE *" export="shared">
doc:		<summary>To protect multithreaded access to `eif_visible_is_off'.</summary>
doc:		<thread_safety>Safe</thread_safety>
doc:	</attribute>
*/
rt_shared EIF_CS_TYPE *eif_cecil_mutex = (EIF_CS_TYPE *) 0;

rt_shared void eif_cecil_init (void);
#define EIF_CECIL_LOCK		EIF_ASYNC_SAFE_CS_LOCK(eif_cecil_mutex)
#define EIF_CECIL_UNLOCK	EIF_ASYNC_SAFE_CS_UNLOCK(eif_cecil_mutex)

#else	/* EIF_THREADS */

#define EIF_CECIL_LOCK
#define EIF_CECIL_UNLOCK

#endif	/* EIF_THREADS */

/* Function declarations */
rt_private int locate(EIF_REFERENCE object, char *name);			/* Locate attribute by name in skeleton */
rt_public int eiflocate (EIF_OBJECT object, char *name);

/*
 * `visible' exception handling
 */

rt_public void eifvisex (void) {
	/* Enable the visible exception */

	RT_GET_CONTEXT
#ifdef EIF_THREADS
	REQUIRE ("Cecil mutex created", eif_cecil_mutex);
#endif
	EIF_CECIL_LOCK;
	eif_visible_is_off = (unsigned char) 0;
	EIF_CECIL_UNLOCK;
}

rt_public void eifuvisex (void) {
	/* Disable visible exception */

	RT_GET_CONTEXT
#ifdef EIF_THREADS
	REQUIRE ("Cecil mutex created", eif_cecil_mutex);
#endif
	EIF_CECIL_LOCK;
	eif_visible_is_off = (unsigned char) 1;
	EIF_CECIL_UNLOCK;
}

/*
 * Type checking
 */

rt_public int eifattrtype (char *attr_name, EIF_TYPE_ID ftype)
	/* Type of `attr_name' defined in class of type `ftype'. */
{
	const struct cnode *sk;	/* Skeleton entry in system */
	const char **n;	/* Pointer in cn_names array */
	int nb_attr;	/* Number of attributes */
	int i;
	uint32 field_type;	/* for scanning type */
	int l_result = EIF_NO_TYPE;
	EIF_TYPE l_ftype = eif_decoded_type(ftype);

	REQUIRE("attr_name not null", attr_name);

	if (l_ftype.id == INVALID_DTYPE) {
		eif_panic ("Unknown dynamic type\n");	/* Check if dynamic exists */
	} else {
		sk = &System(To_dtype(l_ftype.id));	/* Fetch skeleton entry */
		nb_attr = sk->cn_nbattr;	/* Number of attributes */


		for (i = 0, n = sk->cn_names; i < nb_attr; i++, n++)
			if (0 == strcmp(attr_name, *n))
				break;	/* Attribute was found */

		if (i < nb_attr) {
				/* Attribute found */

			field_type = sk->cn_types[i];
			switch (field_type & SK_HEAD) {
				case SK_REF:     l_result = EIF_REFERENCE_TYPE;    break;
				case SK_CHAR8:   l_result = EIF_CHARACTER_8_TYPE;  break;
				case SK_CHAR32:  l_result = EIF_CHARACTER_32_TYPE; break;
				case SK_BOOL:    l_result = EIF_BOOLEAN_TYPE;      break;
				case SK_UINT8:   l_result = EIF_NATURAL_8_TYPE;    break;
				case SK_UINT16:  l_result = EIF_NATURAL_16_TYPE;   break;
				case SK_UINT32:  l_result = EIF_NATURAL_32_TYPE;   break;
				case SK_UINT64:  l_result = EIF_NATURAL_64_TYPE;   break;
				case SK_INT8:    l_result = EIF_INTEGER_8_TYPE;    break;
				case SK_INT16:   l_result = EIF_INTEGER_16_TYPE;   break;
				case SK_INT32:   l_result = EIF_INTEGER_32_TYPE;   break;
				case SK_INT64:   l_result = EIF_INTEGER_64_TYPE;   break;
				case SK_REAL32:  l_result = EIF_REAL_32_TYPE;      break;
				case SK_REAL64:  l_result = EIF_REAL_64_TYPE;      break;
				case SK_EXP:     l_result = EIF_EXPANDED_TYPE;     break;
				case SK_POINTER: l_result = EIF_POINTER_TYPE;      break;
			}
		}
	}
	return l_result;
}

/*
doc:	<routine name="eif_dtype_to_sk_type" return_type="uint32" export="shared">
doc:		<summary>Given a cecil ID, returns the corresponding SK_XX abstract type.</summary>
doc:		<param name="dtype" type="EIF_TYPE_INDEX">cecil ID.</param>
doc:		<thread_safety>Safe</thread_safety>
doc:		<synchronization>None</synchronization>
doc:	</routine>
*/
rt_shared uint32 eif_dtype_to_sk_type (EIF_TYPE_INDEX dtype)
{
	if (dtype == egc_char_dtype) {
		return SK_CHAR8;
	} else if (dtype == egc_wchar_dtype) {
		return SK_CHAR32;
	} else if (dtype == egc_bool_dtype) {
		return SK_BOOL;
	} else if (dtype == egc_uint8_dtype) {
		return SK_UINT8;
	} else if (dtype == egc_uint16_dtype) {
		return SK_UINT16;
	} else if (dtype == egc_uint32_dtype) {
		return SK_UINT32;
	} else if (dtype == egc_uint64_dtype) {
		return SK_UINT64;
	} else if (dtype == egc_int8_dtype) {
		return SK_INT8;
	} else if (dtype == egc_int16_dtype) {
		return SK_INT16;
	} else if (dtype == egc_int32_dtype) {
		return SK_INT32;
	} else if (dtype == egc_int64_dtype) {
		return SK_INT64;
	} else if (dtype == egc_real32_dtype) {
		return SK_REAL32;
	} else if (dtype == egc_real64_dtype) {
		return SK_REAL64;
	} else if (dtype == egc_point_dtype) {
		return SK_POINTER;
	} else {
		if (EIF_IS_EXPANDED_TYPE(System(dtype))) {
			return SK_EXP | dtype;
		} else {
			return SK_REF;
		}
	}
}

/*
doc:	<routine name="eif_sk_type_to_dtype" return_type="EIF_TYPE_INDEX" export="shared">
doc:		<summary>Given a SK_XXX abstract type, returns the corresponding CECIL ID.</summary>
doc:		<param name="sk_type" type="uint32">SK_XX type.</param>
doc:		<thread_safety>Safe</thread_safety>
doc:		<synchronization>None</synchronization>
doc:	</routine>
*/
rt_shared EIF_TYPE_INDEX eif_sk_type_to_dtype (uint32 sk_type)
{
	switch (sk_type & SK_HEAD) {
		case SK_CHAR8: return egc_char_dtype;
		case SK_CHAR32: return egc_wchar_dtype;
		case SK_BOOL: return egc_bool_dtype;
		case SK_UINT8: return egc_uint8_dtype;
		case SK_UINT16: return egc_uint16_dtype;
		case SK_UINT32: return egc_uint32_dtype;
		case SK_UINT64: return egc_uint64_dtype;
		case SK_INT8: return egc_int8_dtype;
		case SK_INT16: return egc_int16_dtype;
		case SK_INT32: return egc_int32_dtype;
		case SK_INT64: return egc_int64_dtype;
		case SK_REAL32: return egc_real32_dtype;
		case SK_REAL64: return egc_real64_dtype;
		case SK_POINTER: return egc_point_dtype;
		case SK_REF:
		case SK_EXP:
			return (EIF_TYPE_INDEX) (sk_type & SK_DTYPE);
		default:
			return 0;
	}
}

/*
 * Object creation
 */

rt_public EIF_OBJECT eifcreate(EIF_TYPE_ID ftype)
{
	/* Create an instance of class 'ftype', but does not call any creation
	 * routine. Return the address in the indirection table (access to the
	 * real object done via a macro (objects are moving). Exceptions will
	 * occur if the object cannot be created for some reason.
	 */

	EIF_REFERENCE object;					/* Eiffel object's physical address */
	EIF_TYPE l_ftype = eif_decoded_type(ftype);

	if (l_ftype.id == INVALID_DTYPE) {
			/* Was not a valid reference type */
		return (EIF_OBJECT) 0;			/* No creation, return null pointer */
	} else {
		object = emalloc(l_ftype.id);		/* Create object */
		return eif_protect(object);			/* Return the indirection pointer */
	}
}

/*
 * Function pointers handling
 */

rt_public EIF_REFERENCE_FUNCTION eifref(char *routine, EIF_TYPE_ID ftype)
{
	/* Look for the routine named 'routine' in the type 'ftype'.
	 * Return a pointer to the routine if found, or the
	 * null pointer if the routine does not exist.
	 */
	
	//TODO: We should use the available generic information!
	
	struct eif_define def = eif_find_feature (routine, ftype, 0);
	if (!def.routine && !eif_visible_is_off) {
		eraise ("Unknown routine (visible?)", EN_PROG);
	}
	return (EIF_REFERENCE_FUNCTION) def.routine;
}

/**
 * A helper function to implement eif_routine.
 * @param routine_name the name of the routine to look for, valid in `context'
 * @param context the context of the routine name
 * @param current the class currently looked at
 * @param context_is_ancestor whether `context' is an ancestor of `current'
 * @return the routine definition with the final name
 */
struct eif_define eif_routine_search(const char *routine_name, EIF_TYPE_INDEX context, EIF_TYPE_INDEX current, int context_is_ancestor) {
	struct eif_define result;
	result.name = NULL;
#ifdef WORKBENCH
	result.feature_id = 0;
#else
	result.routine = NULL;
#endif
	const struct eif_define* defines = Cecil(context).defines;

	//The algorithm goes up and then down the hierarchy to collect the necessary
	// data about a routine. There are basically two "modes" of searching, 
	// depending on whether the context is an ancestor of current .
	if (context_is_ancestor) {
		// If the context is an ancestor, that is we didn't pass it yet, 
		// Then we need to do a search for it, at the moment in the form of a
		// depth-first search. 
		// Renaming, selecting etc. is not interesting on the way up, since the 
		// name only becomes valid if the context is current.
		// However, on the way down we need to apply renaming, and if the search
		// yielded multiple results, select the one that was "selected"
		
		for (int i = 0; i < Cecil(current).inherits_count; i++) {
			const struct eif_inherit* inh = &Cecil(current).inherits[i];
			// The context is an ancestor of the parent if it is not the parent.
			struct eif_define def = eif_routine_search(routine_name, context, inh->parent, context != inh->parent);
			// We now need to adapt to redefinitions and renaming
			if (def.name) {
				// Maybe the routine got renamed
				// ToDo: Use binary search
				for (int j = 0; j < inh->renames_count; j++) {
					if (0 == strcmp(inh->renames[j].old_name, def.name)) {
						// Then we need to update the name
						def.name = inh->renames[j].new_name;
					}
				}
				result = def;
				// Maybe the routine was selected 
				// ToDo: Use binary search
				for (int j = 0; j < inh->selects_count; j++) {
					if (0 == strcmp(inh->selects[j], def.name)) {
						// Then we not need to look further
						break;
					}
				}
			}
		}
		if (result.name) {
			// Maybe there was a simple redefinition
			for (int j = 0; j < Cecil(current).defines_count; j++) {
				if (0 == strcmp(Cecil(current).defines[j].name, result.name)) {
					// Then we replace the definition
					result = Cecil(current).defines[j];
				}
			}
		}
	} else {
		// We are at or past the context in the hierarchy and just need to find the 
		// right definition. For this, we apply renaming in reverse on the way up.
		// Looking for the definition in the current class
		for (int j = 0; j < Cecil(current).defines_count; j++) {
			if (0 == strcmp(defines[j].name, routine_name)) {
				// Lucky! We have a definition here, so we do not need to look 
				// further! The definition has already the correct name, so we
				// can simply return it.
				result = defines[j];
				goto end;
			}
		}
		for (int i = 0; i < Cecil(current).inherits_count; i++) {
			const struct eif_inherit* inh = &Cecil(current).inherits[i];
			// We need to look whether the routine got renamed
			const char* old_name = routine_name;
			for (int j = 0; j < inh->renames_count; j++) {
				if (0 == strcmp(inh->renames[j].new_name, routine_name)) {
					// Then we need to update the name
					old_name = inh->renames[j].old_name;
				}
			}			
			// The further iterations are past the context too, so the context 
			// can never be an ancestor anymore
			result = eif_routine_search(old_name, context, inh->parent, 0);
			

			if (result.name) {
				// Found it! We now need to adapt to renaming
				result.name = routine_name;
				// We do not consider the selected status, since the
				// context class is current or a descendent
				// By going back down the tree we apply renaming and redefinitions
				// accordingly.
				// We do not need to look further, one correct version is enough 
				// since we're past the context that defines the routine.
				// If this "path" was undefined, we wouldn't be here.
				break;
			}
		}
	}
	end: return result;
}

rt_public const char* eif_feature_name(struct eif_define* feature_definition) {
	return feature_definition->name;
}

rt_public EIF_TYPE_ID eif_feature_type(struct eif_define* routine_definition) {
	const struct eif_signature* sig = routine_definition->signature;
	if (sig) {
		EIF_TYPE result_type = eif_decoded_type (sig->result_type);
		return eif_encoded_type (result_type);
	}
	return 0;
}

rt_public int eif_feature_argument_count(struct eif_define* feature_definition) {
	const struct eif_signature* sig = feature_definition->signature;
	if (sig && sig->argument_types) {
		int result;
		for (result = 0; sig->argument_types[result] != 0xFFFF; result++);
		return result;
	}
	return 0;
}

rt_public EIF_TYPE_ID eif_feature_argument_type(struct eif_define* feature_definition, int argno) {
	const struct eif_signature* sig = feature_definition->signature;
	if (eif_feature_argument_count(feature_definition) < argno) {
		return 0;
	}
	EIF_TYPE result_type = eif_decoded_type (sig->argument_types[argno-1]);
	return eif_encoded_type (result_type);
}

#ifdef WORKBENCH
rt_public EIF_NATURAL_32 eif_feature_routine_id(struct eif_define* feature_definition, int argno) {
	return feature_definition->feature_id;
}
#else
rt_public EIF_PROCEDURE eif_feature_routine(struct eif_define* feature_definition, int argno) {
	return feature_definition->routine;
}

#ifdef EIF_THREADS
rt_public void (* eif_feature_scoop_pattern(struct eif_define* feature_definition, int argno))(struct eif_scoop_call_data*) {
	if (feature_definition->signature) {
		return feature_definition->signature->scoop_pattern;
	}
	return NULL;
}
#endif
#endif

/*
 * Retrieves routine information about the routine named `routine_name' in the class denoted by `ftype'.
 * The optional argument `context' is the class where `routine_name' points to the intended routine.
 * The context has to be an ancestor to `ftype'.
 * If the result has a name, it may be an attribute or not visible.
 */
rt_public struct eif_define eif_find_feature(const char *routine_name, EIF_TYPE_ID ftype, EIF_TYPE_ID context) {
	ftype = eif_base_type (ftype);
	if (!context) {
		context = ftype;
	} else {
		context = eif_base_type (context);
	}
	
	//We are not interested in the type annotations
	EIF_TYPE l_ftype = eif_decoded_type(ftype);
	EIF_TYPE l_context = eif_decoded_type(context);
	
	return eif_routine_search (routine_name, l_context.id, l_ftype.id, context != ftype);
}

/*
 * Class ID versus dynamic type
 */

rt_public EIF_TYPE_ID eif_type_by_reference (EIF_REFERENCE object)
{
		/* Return type id of the direct reference "object" */
	if (egc_is_experimental) {
		return eif_encoded_type(eif_new_type(Dftype(object), ATTACHED_FLAG));
	} else {
		CHECK("Same type", Dftype(object) == eif_encoded_type(eif_new_type(Dftype(object), 0)));
		return Dftype(object);
	}
}

rt_public EIF_TYPE_ID eiftype(EIF_OBJECT object)
{
	/* Obsolete. Use "eif_type_by_reference" instead.
	 * Return the Type id of the specified object.
 	 */

	return eif_type_by_reference(eif_access(object));
}

rt_public const char *eifname(EIF_TYPE_ID ftype)
{
	EIF_TYPE l_ftype = eif_decoded_type(ftype);
	if (l_ftype.id == INVALID_DTYPE) {
		return NULL;
	} else {
		return eif_typename(l_ftype);
	}
}

/*
 * Field access (attributes)
 */


rt_public void *eif_field_safe (EIF_REFERENCE object, char *name, int type_int, int * const ret)
{
	/* Like eif_attribute, but perform a type checking between the type
	 * given by "type_int" and the actual type of the attribute.
	 * Return EIF_WRONG_TYPE, if this fails.
	 * Should be preceded by a cast to the proper type, e.g. *(EIF_INTEGER_32 *) when
	 * type of attribute is an INTEGER_32.
	 */

	void *addr;
	int tid;

	addr = eifaddr (object, name, ret);

	if (*ret != EIF_CECIL_OK)	/* Was "eifaddr" successfull? */
		return addr;	/* Return "addr" with error code in "ret". */

	tid = eif_type_by_reference (object);	/* Get type id for "eif_attribute_type" */
	if (tid == EIF_NO_TYPE)	/* No type id? */
		eif_panic ("Object has no type id.");/* Should not happen. */

	if (eif_attribute_type (name, tid) != type_int)	/* Do types match. */
	{
		*ret = EIF_WRONG_TYPE;	/* Wrong type. */
		return &eif_default_pointer;
	}

	return addr;	/* Return "addr" anyway. */


} 	/* eif_field_safe */


rt_public EIF_INTEGER eifaddr_offset(EIF_REFERENCE object, char *name, int * const ret)
{
	/*
	 * Returns the physical address of the attribute named 'name' in the given
	 * object (note that the address of the object is expected -- we do not
	 * want an Hector indirection pointer).
	 * If it fails, "*ret" is EIF_NO_ATTRIBUTE, EIF_CECIL_OK, otherwise.
	 * (was necessary was getting value of basic types failed).
	 */
	int i;							/* Index in skeleton */
#ifdef WORKBENCH
	int32 rout_id;					/* Attribute routine id */
	EIF_TYPE_INDEX dtype;			/* Object dynamic type */
#endif

	i = locate(object, name);		/* Locate attribute in skeleton */
	if (i == EIF_NO_ATTRIBUTE) {					/* Attribute not found */
		if (!eif_visible_is_off)
			eraise ("Unknown attribute", EN_PROG);
		if (ret != NULL)
			*ret = EIF_NO_ATTRIBUTE;	/* Set "*ret" */
		return -1;
	}

	if (ret != NULL)
		*ret = EIF_CECIL_OK; 	/* Set "*ret" for successfull return. */
#ifndef WORKBENCH
	return (System(Dtype(object)).cn_offsets[i]);
#else
	dtype = Dtype(object);
	rout_id = System(dtype).cn_attr[i];
	return wattr(rout_id, dtype);
#endif
}

rt_public int eiflocate (EIF_OBJECT object, char *name) {
	/* Return the index of attribute `name' in EIF_OBJECT `object' */

	return locate (eif_access (object), name);
}

rt_private int locate(EIF_REFERENCE object, char *name)
{
	/* Locate the attribute 'name' in the specified object and return the index
	 * in the cn_offsets array, or EIF_NO_ATTRIBUTE if there is no such attribute.
	 */

	const struct cnode *sk;				/* Skeleton entry in system */
	const char **n;						/* Pointer in cn_names array */
	int nb_attr;					/* Number of attributes */
	int i;

	if (object == (char *) 0)		/* Null pointer */
		return EIF_NO_ATTRIBUTE;					/* Differ the bus error */

	sk = &System(Dtype(object));	/* Fetch skeleton entry */
	nb_attr = sk->cn_nbattr;		/* Number of attributes */

	/* The lookup to find the attribute is done in a linear way. This makes the
	 * access to an attribute slower, by comparaison with a routine call. It is
	 * however possible to bypass Cecil if the object location does not move,
	 * by calling eifaddr() directly and storing the address somewhere. Then
	 * use the C de-referencing mechanism (non-portable accross Eiffel compilers
	 * of course, as ETL does not mention eifaddr)--RAM.
	 */

	for (i = 0, n = sk->cn_names; i < nb_attr; i++, n++)
		if (0 == strcmp(name, *n))
			break;					/* Attribute was found */

	if (i == nb_attr)				/* Attribute not found */
		return EIF_NO_ATTRIBUTE;					/* Will certainly raise a bus error */

	return i;			/* Index in the attribute array */
}

	/* Obsolete */

rt_public void *old_eifaddr(EIF_REFERENCE object, char *name)
{
	/* Old "eif_addr" with previous signature. This function has been
	 * added for compatibility purpose.
	 */

	int ret;
	return eifaddr (object, name, &ret);
}	/* old_eifaddr */

/*
 * Hash table handling
 */

rt_shared char *ct_value(const struct ctable *ct, const char *key)
{
	/* Look for item associated with given key and returns a pointer to its
	 * location in the value array. Return a null pointer if item is not found.
	 */

	rt_uint_ptr pos;		/* Position in H table */
	rt_uint_ptr hsize;		/* Size of H table */
	char **hkeys;		/* Array of keys */

	rt_uint_ptr tryv = 0;	/* Count number of attempts */
	rt_uint_ptr inc;		/* Loop increment */

	/* Initializations */
	hsize = ct->h_size;
	hkeys = ct->h_keys;

	if (hsize == 0)
		return (char *) 0;			/* Item was not found */

	/* Jump from one hashed position to another until we find the value or
	 * go to an empty entry or reached the end of the table.
	 */
	inc = rt_hashcode(key, strlen(key));
	for (
		pos = inc % hsize, inc = 1 + (inc % (hsize - 1));
		tryv < hsize;
		tryv++, pos = (pos + inc) % hsize
	) {
		if (hkeys[pos] == (char *) 0)
			break;
		else if (0 == strcmp(hkeys[pos], key))
			return ct->h_values + (pos * ct->h_sval);
	}

	return (char *) 0;			/* Item was not found */
}

/*
doc:</file>
*/
