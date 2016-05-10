note
	description: "Summary description for {PRODUCER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PRODUCER

create
	make

feature {NONE} -- Initialization
	make (a_buffer: separate BUFFER)
		do
			buffer := a_buffer
		ensure
			buffer = a_buffer
		end

feature
	buffer: separate BUFFER

	produce (a_items: INTEGER)
		require
			a_items > 0
		local
			i: INTEGER
			start: NATURAL_64
		do
			start := current_time_millis
			from
				i := 1
			until
				i > a_items
			loop
				produce_one (buffer)
				i := i + 1
			end
			print ("producer: " + (current_time_millis - start).out + "%N")
		end

	produce_one (a_buffer: like buffer)
		require
			a_buffer.count < a_buffer.capacity
		do
			a_buffer.put(42);
		end
feature {NONE} -- Implementation

	current_time_millis: NATURAL_64
		external
			"C inline use <sys/time.h>"
		alias
			"{
				struct timespec t;
				if (clock_gettime (CLOCK_REALTIME, &t)) {
					return 1;
				} else {
					return t.tv_sec*1000 + t.tv_nsec/1000000;
				}
			}"
		end
end
