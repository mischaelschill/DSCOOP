indexing
	Generator: "Eiffel Emitter 2.7b2"
	external_name: "System.Security.Permissions.EnvironmentPermission"

frozen external class
	SYSTEM_SECURITY_PERMISSIONS_ENVIRONMENTPERMISSION

inherit
	SYSTEM_SECURITY_CODEACCESSPERMISSION
		redefine
			union
		end
	SYSTEM_SECURITY_IPERMISSION
	SYSTEM_SECURITY_ISECURITYENCODABLE
	SYSTEM_SECURITY_ISTACKWALK
	SYSTEM_SECURITY_PERMISSIONS_IUNRESTRICTEDPERMISSION

create
	make_environmentpermission,
	make_environmentpermission_1

feature {NONE} -- Initialization

	frozen make_environmentpermission (state: SYSTEM_SECURITY_PERMISSIONS_PERMISSIONSTATE) is
		external
			"IL creator signature (System.Security.Permissions.PermissionState) use System.Security.Permissions.EnvironmentPermission"
		end

	frozen make_environmentpermission_1 (flag: SYSTEM_SECURITY_PERMISSIONS_ENVIRONMENTPERMISSIONACCESS; path_list: STRING) is
		external
			"IL creator signature (System.Security.Permissions.EnvironmentPermissionAccess, System.String) use System.Security.Permissions.EnvironmentPermission"
		end

feature -- Basic Operations

	intersect (target: SYSTEM_SECURITY_IPERMISSION): SYSTEM_SECURITY_IPERMISSION is
		external
			"IL signature (System.Security.IPermission): System.Security.IPermission use System.Security.Permissions.EnvironmentPermission"
		alias
			"Intersect"
		end

	from_xml (esd: SYSTEM_SECURITY_SECURITYELEMENT) is
		external
			"IL signature (System.Security.SecurityElement): System.Void use System.Security.Permissions.EnvironmentPermission"
		alias
			"FromXml"
		end

	copy: SYSTEM_SECURITY_IPERMISSION is
		external
			"IL signature (): System.Security.IPermission use System.Security.Permissions.EnvironmentPermission"
		alias
			"Copy"
		end

	frozen add_path_list (flag: SYSTEM_SECURITY_PERMISSIONS_ENVIRONMENTPERMISSIONACCESS; path_list: STRING) is
		external
			"IL signature (System.Security.Permissions.EnvironmentPermissionAccess, System.String): System.Void use System.Security.Permissions.EnvironmentPermission"
		alias
			"AddPathList"
		end

	union (other: SYSTEM_SECURITY_IPERMISSION): SYSTEM_SECURITY_IPERMISSION is
		external
			"IL signature (System.Security.IPermission): System.Security.IPermission use System.Security.Permissions.EnvironmentPermission"
		alias
			"Union"
		end

	frozen get_path_list (flag: SYSTEM_SECURITY_PERMISSIONS_ENVIRONMENTPERMISSIONACCESS): STRING is
		external
			"IL signature (System.Security.Permissions.EnvironmentPermissionAccess): System.String use System.Security.Permissions.EnvironmentPermission"
		alias
			"GetPathList"
		end

	frozen is_unrestricted: BOOLEAN is
		external
			"IL signature (): System.Boolean use System.Security.Permissions.EnvironmentPermission"
		alias
			"IsUnrestricted"
		end

	to_xml: SYSTEM_SECURITY_SECURITYELEMENT is
		external
			"IL signature (): System.Security.SecurityElement use System.Security.Permissions.EnvironmentPermission"
		alias
			"ToXml"
		end

	is_subset_of (target: SYSTEM_SECURITY_IPERMISSION): BOOLEAN is
		external
			"IL signature (System.Security.IPermission): System.Boolean use System.Security.Permissions.EnvironmentPermission"
		alias
			"IsSubsetOf"
		end

	frozen set_path_list (flag: SYSTEM_SECURITY_PERMISSIONS_ENVIRONMENTPERMISSIONACCESS; path_list: STRING) is
		external
			"IL signature (System.Security.Permissions.EnvironmentPermissionAccess, System.String): System.Void use System.Security.Permissions.EnvironmentPermission"
		alias
			"SetPathList"
		end

end -- class SYSTEM_SECURITY_PERMISSIONS_ENVIRONMENTPERMISSION
