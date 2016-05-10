note
	description: "Summary description for {BUFFER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	BUFFER

create
	make

feature {NONE} -- Initialization
	make (a_capacity: like capacity)
		do
			capacity := a_capacity
		ensure
			capacity = a_capacity
		end

feature
	capacity: INTEGER
	count: INTEGER

	put (a_item: INTEGER)
		require
			count < capacity
		do
			data[head] := a_item
			head := (head + 1) \\ capacity
			count := count + 1
		end

	get: INTEGER
		require
			count > 0
		do
			Result := data[tail]
			tail := (tail + 1) \\ capacity
			count := count - 1
		end

feature {NONE}
	data: SPECIAL[INTEGER]
		attribute
			create Result.make_filled (0, 4)
		end
	head: INTEGER
	tail: INTEGER

end
