indexing
	Generator: "Eiffel Emitter 2.7b2"
	external_name: "System.Runtime.Remoting.Services.ITrackingHandler"

deferred external class
	SYSTEM_RUNTIME_REMOTING_SERVICES_ITRACKINGHANDLER

inherit
	ANY
		undefine
			finalize,
			get_hash_code,
			is_equal,
			to_string
		end

feature -- Basic Operations

	disconnected_object (obj: ANY) is
		external
			"IL deferred signature (System.Object): System.Void use System.Runtime.Remoting.Services.ITrackingHandler"
		alias
			"DisconnectedObject"
		end

	marshaled_object (obj: ANY; or_: SYSTEM_RUNTIME_REMOTING_OBJREF) is
		external
			"IL deferred signature (System.Object, System.Runtime.Remoting.ObjRef): System.Void use System.Runtime.Remoting.Services.ITrackingHandler"
		alias
			"MarshaledObject"
		end

	unmarshaled_object (obj: ANY; or_: SYSTEM_RUNTIME_REMOTING_OBJREF) is
		external
			"IL deferred signature (System.Object, System.Runtime.Remoting.ObjRef): System.Void use System.Runtime.Remoting.Services.ITrackingHandler"
		alias
			"UnmarshaledObject"
		end

end -- class SYSTEM_RUNTIME_REMOTING_SERVICES_ITRACKINGHANDLER
