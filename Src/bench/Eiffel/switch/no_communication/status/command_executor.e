indexing
	description: "Calls commands outside the eiffel environment."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class COMMAND_EXECUTOR

inherit
	SHARED_EXEC_ENVIRONMENT

feature -- Command Execution

	execute (command: STRING) is
			-- Execute external `command'.
		require
			valid_command: command /= Void
		do
			Execution_environment.system (command)
		end

	execute_with_args (appl_name, args: STRING) is
			-- Execute external command `appl_name' with following arguments.
		require
			appl_name_not_void: appl_name /= Void
			args_not_void: args /= Void
		local
			command: STRING
		do
			create command.make (appl_name.count + args.count + 1)
			command.append (appl_name)
			command.append_character (' ')
			command.append (args)
			Execution_environment.launch (command)
		end
		
feature -- $EiffelGraphicalCompiler$ specific calls

	link_eiffel_driver (c_code_dir,
				system_name,
				prelink_cmd_name,
				driver_name: STRING) is
			-- Link the driver of the precompilation to
			-- the eiffel project.
		do
			eif_link_driver (c_code_dir.to_c, system_name.to_c,
				prelink_cmd_name.to_c, driver_name.to_c)
		end

	invoke_finish_freezing (c_code_dir, freeze_command: STRING; asynchronous: BOOLEAN; workbench_mode: BOOLEAN) is
			-- Invoke the `finish_freezing' script.
		local
			cwd: STRING
		do
				-- Store current working directory
			cwd := Execution_environment.current_working_directory
			
			Execution_environment.change_working_directory (c_code_dir)
			if asynchronous then
				Execution_environment.launch (freeze_command)
			else
				Execution_environment.system (freeze_command)
			end
			Execution_environment.change_working_directory (cwd)
		end

	terminate_c_compilation is
			-- Terminate running c compilation, if any.
		do
		end

feature {NONE} -- Externals

	eif_link_driver (c_code_dir,
			system_name,
			prelink_cmd_name,
			driver_name: ANY) is
		external
			"C"
		end

indexing
	copyright:	"Copyright (c) 1984-2006, Eiffel Software"
	license:	"GPL version 2 see http://www.eiffel.com/licensing/gpl.txt)"
	licensing_options:	"http://www.eiffel.com/licensing"
	copying: "[
			This file is part of Eiffel Software's Eiffel Development Environment.
			
			Eiffel Software's Eiffel Development Environment is free
			software; you can redistribute it and/or modify it under
			the terms of the GNU General Public License as published
			by the Free Software Foundation, version 2 of the License
			(available at the URL listed under "license" above).
			
			Eiffel Software's Eiffel Development Environment is
			distributed in the hope that it will be useful,	but
			WITHOUT ANY WARRANTY; without even the implied warranty
			of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
			See the	GNU General Public License for more details.
			
			You should have received a copy of the GNU General Public
			License along with Eiffel Software's Eiffel Development
			Environment; if not, write to the Free Software Foundation,
			Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA
		]"
	source: "[
			 Eiffel Software
			 356 Storke Road, Goleta, CA 93117 USA
			 Telephone 805-685-1006, Fax 805-685-6869
			 Website http://www.eiffel.com
			 Customer support http://support.eiffel.com
		]"

end -- class COMMAND_EXECUTOR
