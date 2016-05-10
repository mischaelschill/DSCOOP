note
	description: "Summary description for {PIPELINE_STAGE}."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

class
	PIPELINE_STAGE

feature -- Access
	output: DOUBLE

	has_new_data: BOOLEAN

	clear
		do
			has_new_data := False
		end

	is_finished: BOOLEAN

feature -- Work
	finish
		do
			is_finished := True
		end

	produce (a_new_output: DOUBLE)
		require
			not has_new_data and not is_finished
		do
			output := a_new_output
			--print ("Result: " + output.out + "%N")
			has_new_data := True
		end

	square (a_from: separate PIPELINE_STAGE)
		require
			a_from.has_new_data or else a_from.is_finished
		do
			if a_from.has_new_data then
				produce(a_from.output.power (2))
				a_from.clear
			else
				finish
			end
		end

	root (a_from: separate PIPELINE_STAGE)
		require
			a_from.has_new_data or else a_from.is_finished
		do
			if a_from.has_new_data then
				produce(a_from.output.power (0.5))
				a_from.clear
			else
				finish
			end
		end

	add (a_from1, a_from2: separate PIPELINE_STAGE)
		require
			a_from1.has_new_data or else a_from1.is_finished
			a_from2.has_new_data or else a_from2.is_finished
		local
		do
			if a_from1.has_new_data and a_from2.has_new_data then
				produce(a_from1.output + a_from2.output)
				a_from1.clear
				a_from2.clear
			else
				finish
			end
		end

	consume (a_from: separate PIPELINE_STAGE)
		require
			a_from.has_new_data or else a_from.is_finished
		do
			if a_from.has_new_data then
				--print ("Result: " + a_from.output.out + "%N")
				a_from.clear
			else
				finish
			end
		end
end
