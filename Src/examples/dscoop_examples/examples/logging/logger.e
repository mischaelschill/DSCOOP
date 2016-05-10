note
	description: "Summary description for {LOGGER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	LOGGER

inherit
	DATETIME_SUPPORT

create
	make

feature {NONE}
	make
		do
			create log_files.make (5)
		end

	log_files: ARRAYED_LIST[separate LOG_FILE]

	write_log_file (a_log_file: separate LOG_FILE; a_data: ESTRING_8; a_index: INTEGER)
		do
			if a_index < log_files.count then
				write_log_file (log_files[a_index + 1], a_data, a_index + 1)
			end
			a_log_file.write_entry (a_data)
		end

feature
	add_log_file (a_file: separate LOG_FILE)
		do
			log_files.extend (a_file)
		end

	log (a_log_entry: ESTRING_8)
		do
			write_log_file (log_files[1], a_log_entry, 1)
		end

	test (a_number_entries: INTEGER; a_entry: ESTRING_8)
		local
			i: INTEGER
			start: NATURAL_64
		do
			start := current_time_millis
			from
				i := 1
			until
				i > a_number_entries
			loop
				log (a_entry)
				i := i + 1
			end
			print ((current_time_millis - start).out + "%N")
		end
end
