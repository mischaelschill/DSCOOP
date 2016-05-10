note
	description: "The {CONSUMER} consumes items."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	CONSUMER

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

	consume (a_items: INTEGER)
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
				consume_one (buffer)
				i := i + 1
			end
			print ("consumer: " + (current_time_millis - start).out + "%N")
		end

	consume_one (a_buffer: like buffer)
		require
			a_buffer.count > 0
		local
			l_item: INTEGER
		do
			l_item := a_buffer.get();
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
