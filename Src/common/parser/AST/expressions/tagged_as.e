indexing

	description: "Abstract description of a tagged expression";
	date: "$Date$";
	revision: "$Revision$"

class TAGGED_AS

inherit

	EXPR_AS
		redefine
			simple_format
		end;

feature -- Attributes

	tag: ID_AS;
			-- Expression tag

	expr: EXPR_AS;
			-- Expression

feature -- Initialization

	set is
			-- Yacc initialization
		do
			tag ?= yacc_arg (0);
			expr ?= yacc_arg (1);
		ensure then
			expr_exists: expr /= Void;
		end;

feature -- Equivalence

	is_equiv (other: like Current): BOOLEAN is
			-- Is `other' tagged as equivalent to Current?
		do
			Result := deep_equal (tag, other.tag) and then deep_equal (expr, other.expr)
		end;	

feature -- Simple formatting

	simple_format (ctxt: FORMAT_CONTEXT) is
			-- Reconstitute text.
		do
			ctxt.begin;
			if tag /= void then
				ctxt.put_string(tag);
				ctxt.put_text_item (ti_Colon);
				ctxt.put_space
			end;
			ctxt.new_expression;
			expr.simple_format (ctxt);
			ctxt.commit;
		end;

feature {TAGGED_AS}	-- Replication

	set_expr (e: like expr) is
		require
			valid_arg: e /= Void
		do
			expr := e;
		end

end -- class TAGGED_AS
