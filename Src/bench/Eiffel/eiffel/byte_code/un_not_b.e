class UN_NOT_B 

inherit
	UNARY_B
		rename
			Bc_not as operator_constant
		redefine
			generate_operator, is_built_in, print_register
		end;
	
feature

	print_register is
			-- print expression value
		local
			buf: GENERATION_BUFFER
		do
			buf := buffer
			expr.c_type.generate_cast (buf)
			buf.putchar ('!')
			expr.print_register
		end

	generate_operator is
			-- Generate the unary operator
		do
			buffer.putchar ('!');
		end;

	is_built_in: BOOLEAN is
			-- Is the current binary operator a built-in one ?
		do
			Result := context.real_type (expr.type).is_boolean;
		end;

end
