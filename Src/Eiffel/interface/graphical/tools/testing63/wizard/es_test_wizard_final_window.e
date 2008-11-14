indexing
	description: "Summary description for {ES_TEST_WIZARD_FINAL_WINDOW}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ES_TEST_WIZARD_FINAL_WINDOW

inherit
	EB_WIZARD_INTERMEDIARY_STATE_WINDOW
		redefine
			is_final_state,
			wizard_information
		end

	ES_TEST_WIZARD_WINDOW
		redefine
			is_final_state,
			wizard_information
		end

	ES_SHARED_PROMPT_PROVIDER
		export
			{NONE} all
		end

feature {NONE} -- Access

	wizard_information: ES_TEST_WIZARD_INFORMATION
			-- Information user has provided to the wizard

	factory_type: !TYPE [TEST_CREATOR_I]
			-- Factory type used to create tests
		deferred
		end

feature -- Status report

	is_interface_usable: BOOLEAN = True
			-- <Precursor>

feature {NONE} -- Status report

	is_final_state: BOOLEAN
			-- <Precursor>
		do
			Result := True
		end

feature {NONE} -- Basic operations

	proceed_with_current_info
			-- <Precursor>
		local
			l_ts: TEST_SUITE_S
			l_creator: !TEST_CREATOR_I
			l_info: like wizard_information
		do
			if test_suite.is_service_available then
				l_ts := test_suite.service
				if l_ts.processor_registrar.is_valid_type (factory_type, l_ts) then
					l_creator := l_ts.factory (factory_type)
					if l_creator.is_ready then
						l_info := wizard_information
						check l_info /= Void end
						if l_creator.is_valid_configuration (l_info) then
							l_ts.launch_processor (l_creator, l_info, False)
							cancel_actions
						else
							show_error_prompt (e_configuration_not_valid, [])
						end
					else
						show_error_prompt (e_factory_not_ready, [])
					end
				else
					show_error_prompt (e_factory_not_available, [])
				end
			else
				show_error_prompt (e_test_suite_not_available, [])
			end
		end

	show_error_prompt (a_message: !STRING; a_tokens: !TUPLE)
			-- Show error prompt with `a_message'.
		do
			prompts.show_error_prompt (locale_formatter.formatted_translation (a_message, a_tokens), first_window, Void)
		end

feature {NONE} -- Constants

	e_test_suite_not_available: STRING = "Testing service currently not available"
	e_factory_not_available: STRING = "Eiffel test factory currently not available"
	e_factory_not_ready: STRING = "Factory is already creating tests"
	e_configuration_not_valid: STRING = "The provided settings can not be used to create new tests"


end
