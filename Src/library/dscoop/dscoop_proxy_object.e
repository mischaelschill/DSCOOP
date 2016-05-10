note
	description: "{DSCOOP_PROXY_OBJECT} is the type of the external proxy objects. It is used internally and should never be used outside of the runtime."
	author: "Mischael Schill"
	date: "$Date$"
	revision: "$Revision$"

frozen class
	DSCOOP_PROXY_OBJECT

inherit
	DISPOSABLE

create {NONE}
	default_create

feature {NONE}
	object_id: NATURAL_32

	dispose
		do
			send_release
		end

	send_release
		external
			"built_in"
		end
end
