indexing
	Generator: "Eiffel Emitter 2.7b2"
	external_name: "System.Security.Permissions.SecurityAttribute"

deferred external class
	SYSTEM_SECURITY_PERMISSIONS_SECURITYATTRIBUTE

inherit
	SYSTEM_ATTRIBUTE

feature -- Access

	frozen get_unrestricted: BOOLEAN is
		external
			"IL signature (): System.Boolean use System.Security.Permissions.SecurityAttribute"
		alias
			"get_Unrestricted"
		end

	frozen get_action: SYSTEM_SECURITY_PERMISSIONS_SECURITYACTION is
		external
			"IL signature (): System.Security.Permissions.SecurityAction use System.Security.Permissions.SecurityAttribute"
		alias
			"get_Action"
		end

feature -- Element Change

	frozen set_unrestricted (value: BOOLEAN) is
		external
			"IL signature (System.Boolean): System.Void use System.Security.Permissions.SecurityAttribute"
		alias
			"set_Unrestricted"
		end

	frozen set_action (value: SYSTEM_SECURITY_PERMISSIONS_SECURITYACTION) is
		external
			"IL signature (System.Security.Permissions.SecurityAction): System.Void use System.Security.Permissions.SecurityAttribute"
		alias
			"set_Action"
		end

feature -- Basic Operations

	create_permission: SYSTEM_SECURITY_IPERMISSION is
		external
			"IL deferred signature (): System.Security.IPermission use System.Security.Permissions.SecurityAttribute"
		alias
			"CreatePermission"
		end

end -- class SYSTEM_SECURITY_PERMISSIONS_SECURITYATTRIBUTE
