indexing
	Generator: "Eiffel Emitter 2.7b2"
	external_name: "System.Security.Permissions.RegistryPermission"

frozen external class
	SYSTEM_SECURITY_PERMISSIONS_REGISTRYPERMISSION

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
	make_registrypermission_1,
	make_registrypermission

feature {NONE} -- Initialization

	frozen make_registrypermission_1 (access: SYSTEM_SECURITY_PERMISSIONS_REGISTRYPERMISSIONACCESS; path_list: STRING) is
		external
			"IL creator signature (System.Security.Permissions.RegistryPermissionAccess, System.String) use System.Security.Permissions.RegistryPermission"
		end

	frozen make_registrypermission (state: SYSTEM_SECURITY_PERMISSIONS_PERMISSIONSTATE) is
		external
			"IL creator signature (System.Security.Permissions.PermissionState) use System.Security.Permissions.RegistryPermission"
		end

feature -- Basic Operations

	intersect (target: SYSTEM_SECURITY_IPERMISSION): SYSTEM_SECURITY_IPERMISSION is
		external
			"IL signature (System.Security.IPermission): System.Security.IPermission use System.Security.Permissions.RegistryPermission"
		alias
			"Intersect"
		end

	from_xml (esd: SYSTEM_SECURITY_SECURITYELEMENT) is
		external
			"IL signature (System.Security.SecurityElement): System.Void use System.Security.Permissions.RegistryPermission"
		alias
			"FromXml"
		end

	copy: SYSTEM_SECURITY_IPERMISSION is
		external
			"IL signature (): System.Security.IPermission use System.Security.Permissions.RegistryPermission"
		alias
			"Copy"
		end

	frozen add_path_list (access: SYSTEM_SECURITY_PERMISSIONS_REGISTRYPERMISSIONACCESS; path_list: STRING) is
		external
			"IL signature (System.Security.Permissions.RegistryPermissionAccess, System.String): System.Void use System.Security.Permissions.RegistryPermission"
		alias
			"AddPathList"
		end

	union (other: SYSTEM_SECURITY_IPERMISSION): SYSTEM_SECURITY_IPERMISSION is
		external
			"IL signature (System.Security.IPermission): System.Security.IPermission use System.Security.Permissions.RegistryPermission"
		alias
			"Union"
		end

	frozen get_path_list (access: SYSTEM_SECURITY_PERMISSIONS_REGISTRYPERMISSIONACCESS): STRING is
		external
			"IL signature (System.Security.Permissions.RegistryPermissionAccess): System.String use System.Security.Permissions.RegistryPermission"
		alias
			"GetPathList"
		end

	frozen is_unrestricted: BOOLEAN is
		external
			"IL signature (): System.Boolean use System.Security.Permissions.RegistryPermission"
		alias
			"IsUnrestricted"
		end

	to_xml: SYSTEM_SECURITY_SECURITYELEMENT is
		external
			"IL signature (): System.Security.SecurityElement use System.Security.Permissions.RegistryPermission"
		alias
			"ToXml"
		end

	is_subset_of (target: SYSTEM_SECURITY_IPERMISSION): BOOLEAN is
		external
			"IL signature (System.Security.IPermission): System.Boolean use System.Security.Permissions.RegistryPermission"
		alias
			"IsSubsetOf"
		end

	frozen set_path_list (access: SYSTEM_SECURITY_PERMISSIONS_REGISTRYPERMISSIONACCESS; path_list: STRING) is
		external
			"IL signature (System.Security.Permissions.RegistryPermissionAccess, System.String): System.Void use System.Security.Permissions.RegistryPermission"
		alias
			"SetPathList"
		end

end -- class SYSTEM_SECURITY_PERMISSIONS_REGISTRYPERMISSION
