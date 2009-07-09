note
	description: "[
		Contains all information to be handed to the request 
		out header in order create a rfc2109 cookie in the browser
	]"
	legal: "See notice at end of class."
	status: "Prototyping phase"
	date: "$Date$"
	revision: "$Revision$"

class
	XH_COOKIE_ORDER

inherit
	XH_COOKIE
		redefine
			make
		end

create
	make

feature {NONE} -- Initialization

	make (a_name: STRING; a_value: STRING)
			-- Initialization for `Current'.
		require else
			not_a_name_is_detached_or_empty: a_name /= Void and then not a_name.is_empty
			not_a_value_is_detached_or_empty: a_value /= Void and then not a_value.is_empty
		do
				-- Initialize to default values
			set_name (a_name)
			set_value (a_value)
			set_max_age (default_max_age)
			set_path ("")
			set_domain ("")
			set_comment ("")
			set_secure (False)
		ensure then
			name_attached: name /= Void
			value_attached: value /= Void
			max_age_attached: max_age /= Void
			path_attached: path /= Void
			domain_attached: domain /= Void
			comment_attached: comment /= Void
			version_attached: version /= Void
		end

feature -- Access


	max_age: NATURAL assign set_max_age
		-- Optional.  The Max-Age attribute defines the lifetime of the
		-- cookie, in seconds.  The delta-seconds value is a decimal non-
		-- negative integer.  After delta-seconds seconds elapse, the client
		-- should discard the cookie.  A value of zero means the cookie
		-- should be discarded immediately. Set to < 0 to ignore this parameter.

	version: STRING = "1"
		-- Required.  The Version attribute, a decimal integer, identifies to
		-- which version of the state management specification the cookie
		-- conforms.  For this specification, Version=1 applies.

	path: STRING assign set_path
		-- Optional.  The Path attribute specifies the subset of URLs to
		-- which this cookie applies.

	comment: STRING assign set_comment
		-- Optional.  Because cookies can contain private information about a
	    -- user, the Cookie attribute allows an origin server to document its
	    -- intended use of a cookie.  The user can inspect the information to
	    -- decide whether to initiate or continue a session with this cookie.

	domain: STRING  assign set_domain
		-- Optional.  The Domain attribute specifies the domain for which the
		-- cookie is valid.  An explicitly specified domain must always start
		-- with a dot.

	is_secure: BOOLEAN assign set_secure
		-- Optional.  The Secure attribute (with no value) directs the user
		-- agent to use only (unspecified) secure means to contact the origin
		-- server whenever it sends back this cookie.
		-- The user agent (possibly under the user's control) may determine
		-- what level of security it considers appropriate for "secure"
		-- cookies.  The Secure attribute should be considered security
		-- advice from the server to the user agent, indicating that it is in
		-- the session's interest to protect the cookie contents.

feature -- Status setting

	set_max_age (a_max_age: like max_age)
			-- Sets max_age.
		do
			max_age := a_max_age
		ensure
			max_age_set: equal (max_age, a_max_age)
		end

	set_name (a_name: like name)
			-- Sets name.
		require
			a_name_attached: a_name /= Void and then not a_name.is_empty
		do
			name := a_name
		ensure
			name_set: equal (name, a_name)
		end


	set_value (a_value: like value)
			-- Sets value.
		require
			a_value_attached: a_value /= Void and then not a_value.is_empty
		do
			value := a_value
			ensure
			value_set: equal (value, a_value)
		end

	set_path (a_path: like path)
			-- Sets path.
		require
			a_path_attached: a_path /= Void
		do
			path := a_path
		ensure
			path_set: equal (path, a_path)
		end


	set_comment (a_comment: like comment)
			-- Sets comment.
		require
			a_comment_attached: a_comment /= Void
		do
			comment := a_comment
		ensure
			comment_set: equal (comment, a_comment)
		end


	set_domain (a_domain: like domain)
			-- Sets domain.
		require
			a_domain_attached: a_domain /= Void
		do
			domain := a_domain
		ensure
			domain_set: equal (domain, a_domain)
		end


	set_secure (a_secure: BOOLEAN)
			-- Sets secure.	
		do
			is_secure := a_secure
		ensure
			secure_set: equal (is_secure, a_secure)
		end

feature -- Basic operations

	render_to_string: STRING
			-- Generates the string value for headers_out:
			--	 set-cookie      =       "Set-Cookie:" cookies
			--   cookies         =       1#cookie
			--   cookie          =       NAME "=" VALUE *(";" cookie-av)
			--   NAME            =       attr
			--   VALUE           =       value
			--   cookie-av       =       "Comment" "=" value
			--                   |       "Domain" "=" value
			--                   |       "Max-Age" "=" value
			--                   |       "Path" "=" value
			--                   |       "Secure"
			--                   |       "Version" "=" 1*DIGIT
		local
			l_escaper: XU_ESCAPER
		do
			create l_escaper.make

				-- Name and Value are required
			Result := {XU_CONSTANTS}.Cookie_start + l_escaper.escape_cookie_text (name) + {XU_CONSTANTS}.Cookie_eq + l_escaper.escape_cookie_text (value)
				-- Comment is optional
			if not comment.is_empty then
				Result := Result + {XU_CONSTANTS}.Cookie_sq + {XU_CONSTANTS}.Cookie_comment + l_escaper.escape_cookie_text (comment)
			end
				-- Domain is optional
			if not domain.is_empty then
				Result := Result + {XU_CONSTANTS}.Cookie_sq + {XU_CONSTANTS}.Cookie_domain + l_escaper.escape_cookie_text (domain)
			end
				-- Max-age is optional
			if max_age >= 0 then
		 		Result := Result + {XU_CONSTANTS}.Cookie_sq + {XU_CONSTANTS}.Cookie_max_age + max_age.out
		 	end
				-- Path is optional
			if not path.is_empty then
				Result := Result +{XU_CONSTANTS}.Cookie_sq + {XU_CONSTANTS}.Cookie_path + l_escaper.escape_cookie_text (path)
			end
				-- Secure is optional
			if is_secure then
				Result := Result + {XU_CONSTANTS}.Cookie_sq + {XU_CONSTANTS}.Cookie_secure
			end
				-- Version is required
			Result := Result + {XU_CONSTANTS}.Cookie_sq + {XU_CONSTANTS}.Cookie_version + version + {XU_CONSTANTS}.Cookie_end
		ensure
			Result_not_empty: not Result.is_empty
		end


feature {NONE} -- Implementation

	default_max_age: NATURAL
			-- Generates a default max age of 5min
		do
			Result := 300;
		end


invariant
		name_attached: name /= Void
		value_attached: value /= Void
		max_age_attached: max_age /= Void
		path_attached: path /= Void
		domain_attached: domain /= Void
		comment_attached: comment /= Void
		version_attached: version /= Void
end
