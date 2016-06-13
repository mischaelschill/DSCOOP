note
	description : "dscoop demo application"
	date        : "$Date$"
	revision    : "$Revision$"

class
	APPLICATION

inherit
	ARGUMENTS

create
	make

feature {NONE} -- Initialization
	make
			-- Run application.
		local
			l_gc: DSCOOP_GC_SUPPORT
			l_found: BOOLEAN
			i: INTEGER
			l_string_list: ARRAYED_LIST[ESTRING_8]
		do
			-- enable_debug

			if Current.argument_count > 0 then
				l_found := False
				across
					cli_commands as iter
				until
					l_found
				loop
					if iter.item.name ~ Current.argument (1) then
						create l_string_list.make (Current.argument_count - 1)
						from
							i := 2
						until
							i > Current.argument_count
						loop
							l_string_list.extend (Current.argument (i))
							i := i + 1
						end
						iter.item.call (l_string_list)
						l_found := True
					end
				end
				if not l_found then
					print_usage
				end
			else
				print_usage
			end
		end

	cli_commands: LIST[CLI_COMMAND]
		once
			create {ARRAYED_LIST[CLI_COMMAND]}Result.make(9)
			Result.extend (create {DSCOOP_MICROBENCHMARKS})
			Result.extend (create {LOGGING_EXAMPLE})
			Result.extend (create {DINING_PHILOSOPHERS})
			Result.extend (create {CHAT})
			Result.extend (create {PRODUCER_CONSUMER})
			Result.extend (create {PIPELINE_EXAMPLE})
			Result.extend (create {COMPENSATION_EXAMPLE})
			Result.extend (create {MESSAGING})
		end

	print_usage
		do
			io.put_string ("List of available CLI commands:%N")
			across
				cli_commands as iter
			loop
				io.put_string (iter.item.name)
				io.put_new_line
			end
			io.put_new_line
		end

	enable_debug
		external
			"C inline use eif_dscoop.h"
		alias
			"eif_dscoop_set_print_debug_messages (EIF_TRUE)"
		end
end
