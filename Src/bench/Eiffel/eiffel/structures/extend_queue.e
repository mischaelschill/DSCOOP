-- Eiffel class generated by the 2.3 to 3 translator.

class EXTEND_QUEUE [T] 

inherit
	TO_SPECIAL [T]

creation
	make

feature 

	make (n: INTEGER) is
		do
			upper := -1;
				-- (`lower' initialized to 0 by default, so invariant holds)
			allocate_space (0, n)
			count := 0
			out_index := 0
			in_index := 0
			array_capacity := upper - lower + 1
		end;

	allocate_space (minindex, maxindex: INTEGER) is
			--  Allocate memory and initialize indexes.
		require
			valid_indices: maxindex >= minindex
		do
			lower := minindex;
			upper := maxindex;
			make_area (maxindex - minindex + 1)
		end;

	wipe_out is
			-- Remove all items.
		do
			clear_all
			out_index := 0
			in_index := 0
			count := 0
		end

	clear_all is
			--  Reset all items to default values.
		local
			i: INTEGER;
			dead_element: T
		do
			from
				i := lower
			variant
				upper + 1 - i
			until
				i > upper
			loop
				put_i_th (dead_element,i);
				i := i + 1
			end
		end

	empty: BOOLEAN is
			-- Is `Current' empty?
		do
			Result := count = 0
		end

	put_i_th (v: T; i: INTEGER) is
			--  Replace `i'-th entry, if in index interval, by `v'.
		do
			area.put (v,i - lower)
		end;
	
	put, add (v: like item) is
			--  Add `v' to the end of `Current'.
		do
			put_i_th (v,in_index);
			in_index := (in_index + 1) \\ array_capacity
			count := count + 1
		end;
	
	remove is
			--  Remove oldest item.
		do
			out_index := (out_index + 1) \\ array_capacity
			count := count - 1
		end;
	
	item: T is
			--  Oldest item of `Current'
		do
			Result := i_th (out_index)
		end;
	
	i_th (i: INTEGER): T is
			--  Entry at index `i', if in index interval.
		do
			Result := area.item (i - lower)
		end;
	
	is_full: BOOLEAN is
			-- Is `Current' full?
		do
			Result := capacity = count
		end

	capacity: INTEGER is
			-- Number of items that may
			-- be stored into `Current'
		do
			Result := array_capacity - 1
		end

	change_last_item (t: T) is
			-- Change the ouput of the queue
		require
			not empty;
		do
			put_i_th (t, (in_index + array_capacity - 1) \\ array_capacity)
		end;

feature -- Cursor movement

	start is
			-- Put the cursor to the beginning of the cache
		do
			if is_full then
				position := 0
			else
				position := out_index
			end
		end

	after: BOOLEAN is
			-- Are we at the end of the cache, ie at `out_index'
		do
			if is_full then
				Result := position = count
			else
				Result := position = in_index
			end
		end

	forth is
		do
			if is_full then
				position := position + 1
			else
				position := (position + 1) \\ array_capacity
			end
		end

	item_for_iteration: T is
		do	
			Result := i_th (position) 
		end

feature -- Implementation

	position: INTEGER

	in_index, out_index: INTEGER
			-- Youngest and oldest item in the queue.

	array_capacity: INTEGER
			-- Capacity of the queue, equal to `upper - lower + 1'.

	lower: INTEGER
			-- Lower bound of the array.

	upper: INTEGER
			-- Upper bound of the array.

	count: INTEGER
			--  Number of items in `Current'

end

