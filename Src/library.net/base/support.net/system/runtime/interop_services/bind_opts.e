indexing
	generator: "Eiffel Emitter 3.1rc1"
	external_name: "System.Runtime.InteropServices.BIND_OPTS"
	assembly: "mscorlib", "1.0.3300.0", "neutral", "b77a5c561934e089"

frozen expanded external class
	BIND_OPTS

inherit
	VALUE_TYPE

feature -- Access

	frozen cb_struct: INTEGER is
		external
			"IL field signature :System.Int32 use System.Runtime.InteropServices.BIND_OPTS"
		alias
			"cbStruct"
		end

	frozen grf_flags: INTEGER is
		external
			"IL field signature :System.Int32 use System.Runtime.InteropServices.BIND_OPTS"
		alias
			"grfFlags"
		end

	frozen grf_mode: INTEGER is
		external
			"IL field signature :System.Int32 use System.Runtime.InteropServices.BIND_OPTS"
		alias
			"grfMode"
		end

	frozen dw_tick_count_deadline: INTEGER is
		external
			"IL field signature :System.Int32 use System.Runtime.InteropServices.BIND_OPTS"
		alias
			"dwTickCountDeadline"
		end

end -- class BIND_OPTS
