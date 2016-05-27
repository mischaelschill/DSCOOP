/* 
 * File:   rt_cuckoo_hash.h
 * Author: Mischael Schill <mischael.schill@inf.ethz.ch>
 *
 * Created on May 13, 2016, 1:45 PM
 */
#include <stdlib.h>
#include "eif_portable.h"

#ifdef	__cplusplus
extern "C" {
#endif

#ifndef RT_CHT_NAMESPACE
#define RT_CHT_NAME(suffix) error
#endif

#ifndef RT_CHT_KEY_TYPE
#define RT_CHT_KEY_TYPE error
#endif

#ifndef RT_CHT_BUCKETS
#define RT_CHT_BUCKETS_DEFAULTED
#define RT_CHT_BUCKETS 4
#endif

#ifndef RT_CHT_HASHES
#define RT_CHT_HASHES_DEFAULTED
#define RT_CHT_HASHES 4
#endif
	
struct RT_CHT_NAMESPACE() {
	size_t count;
	size_t bins;
	long int a[RT_CHT_HASHES];
	RT_CHT_KEY_TYPE (*keys)[RT_CHT_BUCKETS];
	unsigned char* bin_count;
	#ifdef RT_CHT_VALUE_TYPE
	RT_CHT_VALUE_TYPE (*values)[RT_CHT_BUCKETS];
	#endif
};

struct RT_CHT_NAMESPACE(_iterator) {
	size_t bin;
	char bucket;
	struct RT_CHT_NAMESPACE()* table;
};
	
struct RT_CHT_NAMESPACE();

struct RT_CHT_NAMESPACE(_iterator);

void RT_CHT_NAMESPACE(_init) (struct RT_CHT_NAMESPACE()* self, size_t capacity);

void RT_CHT_NAMESPACE(_deinit) (struct RT_CHT_NAMESPACE()* self);

#ifdef RT_CHT_VALUE_TYPE 
RT_CHT_VALUE_TYPE RT_CHT_NAMESPACE(_item) (struct RT_CHT_NAMESPACE()* self, RT_CHT_KEY_TYPE key);
RT_CHT_VALUE_TYPE* RT_CHT_NAMESPACE(_item_pointer) (struct RT_CHT_NAMESPACE()* self, RT_CHT_KEY_TYPE key);
#endif

EIF_BOOLEAN RT_CHT_NAMESPACE(_has) (struct RT_CHT_NAMESPACE()* self, RT_CHT_KEY_TYPE key);


#ifdef RT_CHT_VALUE_TYPE 
void RT_CHT_NAMESPACE(_extend) (struct RT_CHT_NAMESPACE()* self, RT_CHT_KEY_TYPE key, RT_CHT_VALUE_TYPE value);
#else
void RT_CHT_NAMESPACE(_extend) (struct RT_CHT_NAMESPACE()* self, RT_CHT_KEY_TYPE key);
#endif

#ifdef RT_CHT_VALUE_TYPE 
EIF_BOOLEAN RT_CHT_NAMESPACE(_remove) (struct RT_CHT_NAMESPACE()* self, RT_CHT_KEY_TYPE key, RT_CHT_VALUE_TYPE* oldvalue);
#else
EIF_BOOLEAN RT_CHT_NAMESPACE(_remove) (struct RT_CHT_NAMESPACE()* self, RT_CHT_KEY_TYPE key);
#endif

void RT_CHT_NAMESPACE(_wipe_out) (struct RT_CHT_NAMESPACE()* self);

struct RT_CHT_NAMESPACE(_iterator) RT_CHT_NAMESPACE(_iterator) (struct RT_CHT_NAMESPACE()* self);

void RT_CHT_NAMESPACE(_iterator_forth) (struct RT_CHT_NAMESPACE(_iterator)* self);

EIF_BOOLEAN RT_CHT_NAMESPACE(_iterator_after) (struct RT_CHT_NAMESPACE(_iterator)* self);

RT_CHT_KEY_TYPE RT_CHT_NAMESPACE(_iterator_key) (struct RT_CHT_NAMESPACE(_iterator)* self);

#ifdef RT_CHT_VALUE_TYPE
RT_CHT_VALUE_TYPE RT_CHT_NAMESPACE(_iterator_item) (struct RT_CHT_NAMESPACE(_iterator)* self);
#endif

void RT_CHT_NAMESPACE(_iterator_remove) (struct RT_CHT_NAMESPACE(_iterator)* self);

#ifdef RT_CHT_KEY_DEFAULTED
#undef RT_CHT_KEY_DEFAULTED
#undef RT_CHT_KEY_TYPE 
#endif

#ifdef RT_CHT_BUCKETS_DEFAULTED
#undef RT_CHT_BUCKETS_DEFAULTED
#undef RT_CHT_BUCKETS
#endif

#ifdef RT_CHT_HASHES_DEFAULTED
#undef RT_CHT_HASHES_DEFAULTED
#undef RT_CHT_HASHES
#endif

#ifdef RT_CHT_DEFAULT_VALUE_DEFAULTED
#undef RT_CHT_DEFAULT_VALUE_DEFAULTED
#undef RT_CHT_DEFAULT_VALUE
#endif

#ifdef RT_CHT_KEY_EQUALITY_DEFAULTED
#undef RT_CHT_KEY_EQUALITY_DEFAULTED
#undef RT_CHT_KEY_EQUALITY(l, r)
#endif

#ifdef RT_CHT_HASHCODE_DEFAULTED
#undef RT_CHT_HASHCODE_DEFAULTED
#undef RT_CHT_HASHCODE(key)
#endif

#ifdef	__cplusplus
}
#endif