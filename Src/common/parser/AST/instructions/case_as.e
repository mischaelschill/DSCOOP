indexing
	description	: "Abstract description ao an alternative of a multi_branch %
				  %instruction. Version for Bench."
	date		: "$Date$"
	revision	: "$Revision$"

class CASE_AS

inherit
	AST_EIFFEL
		redefine
			number_of_breakpoint_slots, is_equivalent
		end

create
	initialize

feature {NONE} -- Initialization

	initialize (i: like interval; c: like compound; w_as, t_as: like when_keyword) is
			-- Create a new WHEN AST node.
		require
			i_not_void: i /= Void
		do
			interval := i
			compound := c
			when_keyword := w_as
			then_keyword := t_as
		ensure
			interval_set: interval = i
			compound_set: compound = c
			when_keyword_set: when_keyword = w_as
			then_keyword_set: then_keyword = t_as
		end

feature -- Visitor

	process (v: AST_VISITOR) is
			-- process current element.
		do
			v.process_case_as (Current)
		end

feature -- Roundtrip

	when_keyword, then_keyword: KEYWORD_AS
			-- Keyword "when" and "then" associated with this structure

feature -- Attributes

	interval: EIFFEL_LIST [INTERVAL_AS]
			-- Interval of the alternative

	compound: EIFFEL_LIST [INSTRUCTION_AS]
			-- Compound

feature -- Roundtrip/Location

	complete_start_location (a_list: LEAF_AS_LIST): LOCATION_AS is
		do
			if a_list = Void then
				Result := interval.complete_start_location (a_list)
			else
				Result := when_keyword.complete_start_location (a_list)
			end
		end

	complete_end_location (a_list: LEAF_AS_LIST): LOCATION_AS is
		do
			if compound /= Void then
				Result := compound.complete_end_location (a_list)
			elseif a_list = Void then
					-- Roundtrip mode
				Result := interval.complete_end_location (a_list)
			else
					-- Non-roundtrip mode
				Result := then_keyword.complete_end_location (a_list)
			end
		end

feature -- Comparison

	is_equivalent (other: like Current): BOOLEAN is
			-- Is `other' equivalent to the current object ?
		do
			Result := equivalent (compound, other.compound) and
				equivalent (interval, other.interval)
		end

feature -- Access

	number_of_breakpoint_slots: INTEGER is
			-- Number of stop points
		do
			if compound /= Void then
				Result := compound.number_of_breakpoint_slots
			end
		end

feature {CASE_AS} -- Replication

	set_interval (i: like interval) is
		require
			valid_arg: i /= Void
		do
			interval := i
		end

	set_compound (c: like compound) is
		do
			compound := c
		end

invariant
	interval_not_void: interval /= Void

end -- class CASE_AS
