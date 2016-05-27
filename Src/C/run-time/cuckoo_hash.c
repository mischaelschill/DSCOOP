/* 
 * File:   rt_cuckoo_hash.c
 * Author: Mischael Schill <mischael.schill@inf.ethz.ch>
 *
 * Created on May 13, 2016, 1:45 PM
 */
#include <stdlib.h>
#include "eif_portable.h"
#include "scoop/rt_dscoop.h"

#ifndef RT_CHT_NAMESPACE
#define RT_CHT_NAMESPACE(suffix) error
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

#ifndef RT_CHT_KEY_EQUALITY
#define RT_CHT_KEY_EQUALITY_DEFAULTED
#define RT_CHT_KEY_EQUALITY(l, r) l == r
#endif

#ifndef RT_CHT_HASHCODE
#define RT_CHT_HASHCODE_DEFAULTED
#define RT_CHT_HASHCODE(key) (size_t) key
#endif

// We need a layer of indirection for concatenation so that we can use marcos as
// arguments. Looks silly, but that's the only way it works.
#ifndef ICAT3
#define ICAT3(a, b, c) CAT3(a, b, c)
#endif

#ifndef ICAT2
#define ICAT2(a, b) CAT2(a, b)
#endif

#define RT_CHT_HASH_FUNCTION(a,x,s) (size_t) (a*x) % s

void RT_CHT_NAMESPACE(_init) (struct RT_CHT_NAMESPACE()* self, size_t capacity) 
{
	self->count = 0;
	
	static EIF_NATURAL_32 primes[] = {
		3,
		7,
		13,
		31,
		53,
		97,
		193,
		389,
		769,
		1543,
		3079,
		6151,
		12289,
		24593,
		49157,
		98317,
		196613,
		393241,
		786433,
		1572869,
		3145739,
		6291469,
		12582917,
		25165843,
		50331653,
		100663319,
		201326611,
		402653189,
		805306457,
		1610612741
	};
	
	size_t bins = 1;
	for (int i = 0; capacity > bins * RT_CHT_BUCKETS; i++) {
		bins=primes[i];
	}
	
	self->bins = bins;
	for (int i = 0; i < RT_CHT_HASHES; i++) {
		retry: self->a[i] = random();
		if (self->bins > 1 && (self->a[i] % self->bins) == 0)
			goto retry;
		for (int j = 0; j < i; j++) {
			if (self->a[i] == self->a[j]) {
				goto retry;
			}
		}
	}
	self->keys = calloc (RT_CHT_BUCKETS * self->bins, sizeof (RT_CHT_KEY_TYPE));
	self->bin_count = calloc (self->bins, sizeof (char));
	#ifdef RT_CHT_VALUE_TYPE
		self->values = calloc (RT_CHT_BUCKETS * self->bins, sizeof (RT_CHT_VALUE_TYPE));
	#endif
}

void RT_CHT_NAMESPACE(_deinit) (struct RT_CHT_NAMESPACE()* self) 
{
	self->bins = 0;
	self->count = 0;
	free (self->keys);
	self->keys = NULL;
	free (self->bin_count);
	self->bin_count = NULL;
	#ifdef RT_CHT_VALUE_TYPE
		free (self->values);
		self->values = NULL;
	#endif
}

#ifdef RT_CHT_VALUE_TYPE 
RT_CHT_VALUE_TYPE RT_CHT_NAMESPACE(_item) (struct RT_CHT_NAMESPACE()* self, RT_CHT_KEY_TYPE key)
{
	size_t bins[RT_CHT_HASHES];
	int hashcode = RT_CHT_HASHCODE (key);
	for (int i = 0; i < RT_CHT_HASHES; i++) {
		bins[i] = RT_CHT_HASH_FUNCTION(self->a[i], hashcode, self->bins);
	}
	for (int i = 0; i < RT_CHT_HASHES; i++) {
		for (int j = 0; j < self->bin_count[bins[i]]; j++) {
			if (RT_CHT_KEY_EQUALITY(self->keys[bins[i]][j], key)) {
				return self->values[bins[i]][j];
			}
		}
	}
	RT_CHT_VALUE_TYPE result;
	memset (&result, 0, sizeof (RT_CHT_VALUE_TYPE));

	return result;
}

RT_CHT_VALUE_TYPE* RT_CHT_NAMESPACE(_item_pointer) (struct RT_CHT_NAMESPACE()* self, RT_CHT_KEY_TYPE key)
{
	size_t bins[RT_CHT_HASHES];
	int hashcode = RT_CHT_HASHCODE (key);
	for (int i = 0; i < RT_CHT_HASHES; i++) {
		bins[i] = RT_CHT_HASH_FUNCTION(self->a[i], hashcode, self->bins);
	}
	for (int i = 0; i < RT_CHT_HASHES; i++) {
		for (int j = 0; j < self->bin_count[bins[i]]; j++) {
			if (RT_CHT_KEY_EQUALITY(self->keys[bins[i]][j], key)) {
				return &self->values[bins[i]][j];
			}
		}
	}
	return NULL;
}
#endif

EIF_BOOLEAN RT_CHT_NAMESPACE(_has) (struct RT_CHT_NAMESPACE()* self, RT_CHT_KEY_TYPE key)
{
	size_t bins[RT_CHT_HASHES];
	int hashcode = RT_CHT_HASHCODE (key);
	for (int i = 0; i < RT_CHT_HASHES; i++) {
		bins[i] = RT_CHT_HASH_FUNCTION(self->a[i], hashcode, self->bins);
	}
	for (int i = 0; i < RT_CHT_HASHES; i++) {
		for (int j = 0; j < self->bin_count[bins[i]]; j++) {
			if (RT_CHT_KEY_EQUALITY(self->keys[bins[i]][j], key)) {
				return 1;
			}
		}
	}
	return 0;
}

void RT_CHT_NAMESPACE(_rehash) (struct RT_CHT_NAMESPACE()* self, ssize_t new_capacity) {
	if (new_capacity == 0) {
		new_capacity = self->bins * RT_CHT_BUCKETS;
	}
	//This is going nowhere, we should resize the table!
	//(It might be possible that a simple change of the hash function does the 
	// trick also, but by resizing we are on the safe side)
	struct RT_CHT_NAMESPACE() new_table;
	// The capacity is the number of buckets times the number of bins, so to double it we need to 
	// multiply the number of bins with two times the number of buckets, which is RT_CHT_BUCKETS
	RT_CHT_NAMESPACE(_init) (&new_table, new_capacity);
				
	for (size_t i = 0; i < self->bins; i++) {
		for (size_t j = 0; j < self->bin_count[i]; j++) {
			#ifdef RT_CHT_VALUE_TYPE
				RT_CHT_NAMESPACE(_extend) (&new_table, self->keys[i][j], self->values[i][j]);
			#else
				RT_CHT_NAMESPACE(_extend) (&new_table, self->keys[i][j]);
			#endif
		}
	}
	
	RT_CHT_NAMESPACE(_deinit) (self);
	memcpy (self, &new_table, sizeof (struct RT_CHT_NAMESPACE()));
}

#ifdef RT_CHT_VALUE_TYPE 
void RT_CHT_NAMESPACE(_extend) (struct RT_CHT_NAMESPACE()* self, RT_CHT_KEY_TYPE key, RT_CHT_VALUE_TYPE value)
#else
void RT_CHT_NAMESPACE(_extend) (struct RT_CHT_NAMESPACE()* self, RT_CHT_KEY_TYPE key)
#endif
{
	for (int tries = 0; tries < 3; tries++) {
		size_t bins[RT_CHT_HASHES];
		int hashcode = RT_CHT_HASHCODE (key);
		for (int i = 0; i < RT_CHT_HASHES; i++) {
			bins[i] = RT_CHT_HASH_FUNCTION(self->a[i], hashcode, self->bins);
		}
		
		//We try to put it in the bin with the least count
		int min_bin;
		int min_bin_bucket_count = 127;
		for (int i = 0; i < RT_CHT_HASHES && min_bin_bucket_count > 1; i++) {
			if (self->bin_count[bins[i]] < min_bin_bucket_count) {
				min_bin = i;
				min_bin_bucket_count = self->bin_count[bins[i]];
			}
		}
		if (min_bin_bucket_count < RT_CHT_BUCKETS) {
			int selected_bucket = bins[min_bin];
			self->keys[selected_bucket][min_bin_bucket_count] = key;
			#ifdef RT_CHT_VALUE_TYPE 
				self->values[selected_bucket][min_bin_bucket_count] = value;
			#endif
			self->bin_count[selected_bucket]++;
			self->count++;
			return;
		}

		// All bins are full, we need to shift one out
		int chosen_bin = bins[random() % RT_CHT_HASHES];

		//We kick out the oldest key
		RT_CHT_KEY_TYPE kicked_out_key = self->keys[chosen_bin][0];
		for (size_t i = 1; i < RT_CHT_BUCKETS; i++) {
			self->keys[chosen_bin][i - 1] = self->keys[chosen_bin][i];
		}
		self->keys[chosen_bin][RT_CHT_BUCKETS - 1] = key;
		key = kicked_out_key;
		
		#ifdef RT_CHT_VALUE_TYPE
			//We do the same for the value
			RT_CHT_VALUE_TYPE kicked_out_value = self->values[chosen_bin][0];
			for (size_t i = 1; i < RT_CHT_BUCKETS; i++) {
				self->values[chosen_bin][i - 1] = self->values[chosen_bin][i];
			}
			self->values[chosen_bin][RT_CHT_BUCKETS - 1] = value;
			value = kicked_out_value;
		#endif
	}
	
	RT_CHT_NAMESPACE(_rehash) (self, self->bins * 2 * RT_CHT_BUCKETS);
	#ifdef RT_CHT_VALUE_TYPE
		RT_CHT_NAMESPACE(_extend) (self, key, value);
	#else
		RT_CHT_NAMESPACE(_extend) (self, key);
	#endif
}


#ifdef RT_CHT_VALUE_TYPE 
EIF_BOOLEAN RT_CHT_NAMESPACE(_remove) (struct RT_CHT_NAMESPACE()* self, RT_CHT_KEY_TYPE key, RT_CHT_VALUE_TYPE* oldvalue)
#else
EIF_BOOLEAN RT_CHT_NAMESPACE(_remove) (struct RT_CHT_NAMESPACE()* self, RT_CHT_KEY_TYPE key)
#endif
{
	size_t bins[RT_CHT_HASHES];
	int hashcode = RT_CHT_HASHCODE (key);
	for (int i = 0; i < RT_CHT_HASHES; i++) {
		bins[i] = RT_CHT_HASH_FUNCTION(self->a[i], hashcode, self->bins);
	}
	for (int i = 0; i < RT_CHT_HASHES; i++) {
		for (int j = 0; j < self->bin_count[bins[i]]; j++) {
			if (RT_CHT_KEY_EQUALITY(self->keys[bins[i]][j], key)) {
				#ifdef RT_CHT_VALUE_TYPE
				if (oldvalue) {
					*oldvalue = self->values[bins[i]][j];
				}
				#endif
				
				for (int k = j + 1; k < self->bin_count[bins[i]]; k++) {
					self->keys[bins[i]][k - 1] = self->keys[bins[i]][k];
					#ifdef RT_CHT_VALUE_TYPE
						self->values[bins[i]][k - 1] = self->values[bins[i]][k];
					#endif
				}
				memset (&self->keys[bins[i]][RT_CHT_BUCKETS - 1], 0, sizeof(RT_CHT_KEY_TYPE));
				self->bin_count[bins[i]]--;
				self->count--;
				//TODO: We could add shrinking here, but for this we need to 
				//remember the original capacity so that we do not shrink below
				//it...
				return 1;
			}
		}
	}
	
	return 0;
}

void RT_CHT_NAMESPACE(_wipe_out) (struct RT_CHT_NAMESPACE()* self)
{
	memset (self->bin_count, 0, self->bins);
	memset (self->keys, 0, self->bins * RT_CHT_BUCKETS * sizeof (RT_CHT_KEY_TYPE));
	#ifdef RT_CHT_VALUE_TYPE 
		memset (self->values, 0, self->bins * RT_CHT_BUCKETS * sizeof (RT_CHT_VALUE_TYPE));
	#endif
	self->count = 0;
}

size_t RT_CHT_NAMESPACE(_count) (struct RT_CHT_NAMESPACE()* self)
{
	return self->count;
}

void RT_CHT_NAMESPACE(_iterator_forth) (struct RT_CHT_NAMESPACE(_iterator)* self)
{
	self->bucket++;
	while (self->bin < self->table->bins && self->bucket >= self->table->bin_count[self->bin]) {
		self->bucket = 0;
		self->bin++;
	}
	return;
}

EIF_BOOLEAN RT_CHT_NAMESPACE(_iterator_after) (struct RT_CHT_NAMESPACE(_iterator)* self)
{
	return self->bin >= self->table->bins;
}

RT_CHT_KEY_TYPE RT_CHT_NAMESPACE(_iterator_key) (struct RT_CHT_NAMESPACE(_iterator)* self)
{
	return self->table->keys[self->bin][(size_t)self->bucket];
}

RT_CHT_KEY_TYPE* RT_CHT_NAMESPACE(_iterator_key_pointer) (struct RT_CHT_NAMESPACE(_iterator)* self)
{
	return &self->table->keys[self->bin][(size_t)self->bucket];
}

#ifdef RT_CHT_VALUE_TYPE
RT_CHT_VALUE_TYPE RT_CHT_NAMESPACE(_iterator_item) (struct RT_CHT_NAMESPACE(_iterator)* self)
{
	return self->table->values[self->bin][(size_t)self->bucket];
}

RT_CHT_VALUE_TYPE* RT_CHT_NAMESPACE(_iterator_item_pointer) (struct RT_CHT_NAMESPACE(_iterator)* self)
{
	return &self->table->values[self->bin][(size_t)self->bucket];
}
#endif

void RT_CHT_NAMESPACE(_iterator_remove) (struct RT_CHT_NAMESPACE(_iterator)* self)
{
	for (int k = self->bucket + 1; k < self->table->bin_count[self->bin]; k++) {
		self->table->keys[self->bin][k - 1] = self->table->keys[self->bin][k];
		#ifdef RT_CHT_VALUE_TYPE
			self->table->values[self->bin][k - 1] = self->table->values[self->bin][k];
		#endif
	}
	self->table->bin_count[self->bin]--;
	memset (&self->table->keys[self->bin][RT_CHT_BUCKETS - 1], 0, sizeof (RT_CHT_KEY_TYPE));
	#ifdef RT_CHT_VALUE_TYPE
		memset (&self->table->values[self->bin][RT_CHT_BUCKETS - 1], 0, sizeof (RT_CHT_VALUE_TYPE));
	#endif
	self->table->count--;
	self->bucket--;
	RT_CHT_NAMESPACE(_iterator_forth) (self);
}

struct RT_CHT_NAMESPACE(_iterator) RT_CHT_NAMESPACE(_iterator) (struct RT_CHT_NAMESPACE()* self)
{
	struct RT_CHT_NAMESPACE(_iterator) result;
	result.bin = 0;
	result.bucket = -1;
	result.table = self;
	RT_CHT_NAMESPACE(_iterator_forth) (&result);
	
	return result;
}

#ifdef RT_CHT_BUCKETS_DEFAULTED
#undef RT_CHT_BUCKETS_DEFAULTED
#undef RT_CHT_BUCKETS
#endif

#ifdef RT_CHT_HASHES_DEFAULTED
#undef RT_CHT_HASHES_DEFAULTED
#undef RT_CHT_HASHES
#endif

#ifdef RT_CHT_KEY_EQUALITY_DEFAULTED
#undef RT_CHT_KEY_EQUALITY_DEFAULTED
#undef RT_CHT_KEY_EQUALITY
#endif

#ifdef RT_CHT_HASHCODE_DEFAULTED
#undef RT_CHT_HASHCODE_DEFAULTED
#undef RT_CHT_HASHCODE
#endif

#undef RT_CHT_HASH_FUNCTION
#undef RT_CHT_ITERATOR
#undef RT_CHT_IMPL_ITERATOR_KEY
#undef RT_CHT_COMPARISON_DEFAULT
#undef RT_CHT_HASHCODE_DEFAULT