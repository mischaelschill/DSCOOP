note
	description: "Summary description for {DATETIME_SUPPORT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	DATETIME_SUPPORT

feature
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
