class
	TEST

create
	make

feature

	make
		local
			t: TUPLE [pebble: ANY]
			internal_items_stone_data: SPECIAL [TUPLE [pebble: ANY]]
		do
			internal_items_stone_data [1] := t
			t := [create {ANY}]
			t.pebble := ""
		end

end
