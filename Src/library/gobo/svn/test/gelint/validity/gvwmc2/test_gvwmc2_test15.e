indexing

	description:

		"Test for validity rule GVWMC-2"

	remark: "[
		In this test the binary integer constant '0b100000000' (i.e. 256) in
		'{INTEGER_8} 0b100000000' is too big to be representable as an INTEGER_8.

		This rule is missing in ECMA 367-2.
		ISE reports a syntax error.
	]"

	copyright: "Copyright (c) 2009, Eric Bezault and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

class TEST_GVWMC2_TEST15

inherit

	GELINT_TEST_CASE

create

	make_default

feature -- Test

	test_validity is
			-- Test for validity rule GVWMC-2.
		do
			compile_and_test ("test15")
		end

feature {NONE} -- Implementation

	rule_dirname: STRING is
			-- Name of the directory containing the tests of the rule being tested
		do
			Result := file_system.nested_pathname ("${GOBO}", <<"test", "gelint", "validity", "gvwmc2">>)
			Result := Execution_environment.interpreted_string (Result)
		end

	testdir: STRING is
			-- Name of temporary directory where to run the test
		do
			Result := "Ttest15"
		end

end
