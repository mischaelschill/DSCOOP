class PROMPT_D_DEMO_WINDOW

inherit

	ANY_DEMO_WINDOW

	PROMPT_D
		rename
			make as prompt_d_make
		end

creation

	make

feature

	main_widget: WIDGET is
		do
			Result:=Current
		end

	make(a_name: STRING; a_parent: COMPOSITE) is
		do
			prompt_d_make (a_name, a_parent)
			allow_resize
			set_widgets
		end

	set_widgets is
		do
		end

	work (arg: INTEGER_REF) is
		do
		end

end -- class PROMPT_D_DEMO_WINDOW
