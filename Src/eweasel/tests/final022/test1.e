
--| Copyright (c) 1993-2006 University of Southern California and contributors.
--| All rights reserved.
--| Your use of this work is governed under the terms of the GNU General
--| Public License version 2.

class TEST1 [G]
create
	make
feature
	make is
		do
			print (value1 = Void); io.new_line
			print (value2 = Void); io.new_line
		end

	value1: G
	
	value2: G is 
		do 
		end

end
