note
	description: "A {PHILOSOPHER} likes to eat and think."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	PHILOSOPHER

create
	place

feature
	thinking_time, eating_time: INTEGER_64

	place (a_name: ESTRING_8; l, r: separate FORK)
			-- Places the processor between two forks and gives him a name
		do
			name := a_name
			left := l
			right := r

			thinking_time := 0 -- 1_000_000
			eating_time := 0 -- 1_000_000
		ensure
			name = a_name
			left = l
			right = r
		end

	name: ESTRING_8
		-- The name of the philosopher

	left, right: separate FORK

	eat (a_count: NATURAL)
			-- Do the thinking / eating cycle for `a_count' times
		local
			i, j: NATURAL
			start: NATURAL_64
		do
			start := current_time_millis

			from
				i := 1
			until
				i > a_count
			loop
				-- Think
				separate left as l, right as r do
					j := l.use
					j := r.use
				end
				i := i + 1
			end
			print ((current_time_millis - start).out + "%N")
--			print (name.out + ": " + (current_time_millis - start).out + "%N")
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
