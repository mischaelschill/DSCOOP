note
	description: "Summary description for {POLITICIAN}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	POLITICIAN

inherit
	DSCOOP_COMPENSATION_SUPPORT

feature
	say_something
		do
			print ("I am going to do this!%N")
			compensation (agent do print ("I never sait that I will do this.%N") end)
		end

end
