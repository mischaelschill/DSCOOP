note
	description: "[
		Base implementation for all root or localized service containers.
	]"
	legal: "See notice at end of class."
	status: "See notice at end of class.";
	date: "$Date$";
	revision: "$Revision $"

deferred class
	SERVICE_PROVIDER_CONTAINER

inherit
	SERVICE_CONTAINER_I

	SERVICE_PROVIDER_I

	SHARED_SERVICE_PROVIDER
		export
			{NONE} all
		end

feature {NONE} -- Initialization

	make
			-- Initialize the service container.
		do
			create services.make (13)
		end

feature {NONE} -- Access

	services: attached HASH_TABLE [attached SERVICE_CONCEALER_I, attached HASHABLE]
			-- Local registered services indexed by a service type hash code
			--
			-- Key: Computed type hash using `type_hash'
			-- Value: Service object

feature -- Status report

	is_service_proffered (a_type: attached TYPE [SERVICE_I]; a_promote: BOOLEAN): BOOLEAN
			-- <Precursor>.
		do
			Result := services.has (type_hash (a_type))
		end

feature -- Query

	frozen service (a_type: attached TYPE [SERVICE_I]): detachable SERVICE_I
			-- <Precursor>
		local
			l_obj: ANY
		do
			l_obj := internal_service (a_type)
			if l_obj /= Void then
				Result := reveal (l_obj)
			end

			if Result /= Void and then attached {attached SERVICE_PROVIDER_I} Current as l_provider and then Result.site /= l_provider then
				Result.site := l_provider
			end
		end

feature {NONE} -- Query

	frozen type_hash (a_type: attached TYPE [SERVICE_I]): attached HASHABLE
			-- Retrieves a hashable object given a type.
			-- Note: This is added for compatiblity, given that {TYPE} is not yet {HASHABLE}. When this is
			--       changed this feature is to be removed and the type used directly.
			--
			-- `a_type': The service type to retrieve a hashable object for.
			-- `Result': A hashable object to use with `services'.
		do
			if attached {HASHABLE} a_type as l_hashable then
				Result := l_hashable
			else
				Result := a_type.generating_type.as_attached
			end
		end

	internal_service (a_type: attached TYPE [SERVICE_I]): detachable ANY
			-- Attempts to retrieve a service or a service concealer ({SERVICE_CONCEALER_I}).
			--
			-- `a_type': The service type to query the `services' table with.
			-- `Result': A service object or a service concealer object.
		do
			if is_service_proffered (a_type, True) then
				Result := services [type_hash (a_type)]
			end
		end

feature -- Extension

	register (a_type: attached TYPE [SERVICE_I]; a_service: attached SERVICE_I; a_promote: BOOLEAN)
			-- <Precursor>
		do
			if a_promote and then attached {SERVICE_CONTAINER_S} service_provider.service ({SERVICE_CONTAINER_S}) as l_container then
				l_container.register (a_type, a_service, False)
			else
					-- Not promoted or Current is the top-level provider.
				services.put (create {SERVICE_STATIC_CONCEALER}.make (a_service), type_hash (a_type))
			end
		end

	register_with_activator (a_type: attached TYPE [SERVICE_I]; a_activator: attached FUNCTION [ANY, TUPLE, detachable SERVICE_I] a_promote: BOOLEAN)
			-- <Precursor>
		do
			if a_promote and then attached {SERVICE_CONTAINER_S} service_provider.service ({SERVICE_CONTAINER_S}) as l_container then
				l_container.register_with_activator (a_type, a_activator, False)
			else
					-- Not promoted or Current is the top-level provider.
				services.put (create {SERVICE_DELAYED_CONCEALER}.make (a_activator), type_hash (a_type))
			end
		end

feature -- Removal

	revoke (a_type: attached TYPE [SERVICE_I]; a_promote: BOOLEAN)
			-- <Precursor>
		do
			if is_service_proffered (a_type, False) then
				services.remove (type_hash (a_type))
			end
		end

feature {NONE} -- Basic operations

	reveal (a_obj: attached ANY): detachable SERVICE_I
			-- Extracts `a_service' from a possible concealed service.s
			--
			-- `a_service': The service to reveal.
			-- `Result': A revealed service or Void is no service could be revealed.
		do
			if attached {SERVICE_CONCEALER_I} a_obj as l_concealer then
				Result := l_concealer.service
			else
				Result ?= a_obj
			end
		end

;note
	copyright:	"Copyright (c) 1984-2008, Eiffel Software"
	license:	"GPL version 2 (see http://www.eiffel.com/licensing/gpl.txt)"
	licensing_options:	"http://www.eiffel.com/licensing"
	copying: "[
			This file is part of Eiffel Software's Eiffel Development Environment.
			
			Eiffel Software's Eiffel Development Environment is free
			software; you can redistribute it and/or modify it under
			the terms of the GNU General Public License as published
			by the Free Software Foundation, version 2 of the License
			(available at the URL listed under "license" above).
			
			Eiffel Software's Eiffel Development Environment is
			distributed in the hope that it will be useful,	but
			WITHOUT ANY WARRANTY; without even the implied warranty
			of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
			See the	GNU General Public License for more details.
			
			You should have received a copy of the GNU General Public
			License along with Eiffel Software's Eiffel Development
			Environment; if not, write to the Free Software Foundation,
			Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA
		]"
	source: "[
			 Eiffel Software
			 356 Storke Road, Goleta, CA 93117 USA
			 Telephone 805-685-1006, Fax 805-685-6869
			 Website http://www.eiffel.com
			 Customer support http://support.eiffel.com
		]"

end -- class {SERVICE_PROVIDER_CONTAINER}
