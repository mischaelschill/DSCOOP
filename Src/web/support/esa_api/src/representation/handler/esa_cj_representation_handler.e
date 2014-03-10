note
	description: "Concreate class to converts data into the CJ representation."
	date: "$Date$"
	revision: "$Revision$"

class
	ESA_CJ_REPRESENTATION_HANDLER

inherit

	ESA_REPRESENTATION_HANDLER

	REFACTORING_HELPER
create
	make

feature -- View

	home_page (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- Home page representation
		local
			l_cj: ESA_CJ_ROOT_PAGE
		do
			if attached req.http_host as l_host then
				create l_cj.make ("http://"+l_host, req.execution_variable ("user"))
				if attached l_cj.representation as l_cj_api then
					new_response_get (req, res,l_cj_api)
				end
			end
		end

	problem_report (req: WSF_REQUEST; res: WSF_RESPONSE; a_report: REPORT)
			-- <Precursor>
		local
			l_cj: ESA_CJ_REPORT_DETAIL_PAGE
		do
			if attached req.http_host as l_host then
				create l_cj.make ("http://" + l_host, a_report, req.execution_variable ("user"))
				if attached l_cj.representation as l_cj_api then
					new_response_get (req, res, l_cj_api)
				end
			end
		end

	problem_reports_guest (req: WSF_REQUEST; res: WSF_RESPONSE; a_report_view: ESA_REPORT_VIEW)
			-- Problem reports representation for a guest user
		local
			l_hp: ESA_CJ_REPORT_PAGE
		do
			if attached req.http_host as l_host then
				create l_hp.make ("http://" + l_host, a_report_view)
				if attached l_hp.representation as l_report_page then
					new_response_get (req, res, l_report_page)
				end
			end
		end


	problem_user_reports  (req: WSF_REQUEST; res: WSF_RESPONSE; a_report_view: ESA_REPORT_VIEW)
			-- Problem reports representation for a given user
		local
			l_hp: ESA_CJ_REPORT_PAGE
			l_pages: INTEGER
		do
			if attached req.http_host as l_host then
				create l_hp.make ("http://" + l_host, a_report_view)
				if attached l_hp.representation as l_home_page then
					new_response_get (req, res, l_home_page)
				end
			end
		end


	not_found_page (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- Home page representation
		local
			l_cj: ESA_CJ_ROOT_PAGE
		do
			if attached req.http_host as l_host then
				create l_cj.make_with_error ("http://" + l_host, "The resource " + req.path_info.as_string_8 + "was not found", 404, req.execution_variable ("user"))
				if attached l_cj.representation as l_representation then
					new_response_get_404 (req, res, l_representation)
				end
			end
		end

	login_page (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- Login page
		local
			l_cj: ESA_CJ_ROOT_PAGE
		do
			if attached req.http_host as l_host then
				create l_cj.make ("http://"+l_host, req.execution_variable ("user"))
				if attached l_cj.representation as l_cj_api then
					new_response_get (req, res,l_cj_api)
				end
			end
		end

	logout_page (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- <Precursor>
		local
			l_cj: ESA_CJ_ROOT_PAGE
		do
			if attached req.http_host as l_host then
				create l_cj.make ("http://"+l_host, Void)
				if attached l_cj.representation as l_cj_api then
					new_response_access_denied (req, res,l_cj_api)
				end
			end
		end

	bad_request_page (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- <Precursor>
		local
			l_cj: ESA_CJ_ROOT_PAGE
		do
			if attached req.http_host as l_host then
				create l_cj.make_with_error ("http://" + l_host, "Bad Request " + req.path_info.as_string_8, 400, req.execution_variable ("user"))
				if attached l_cj.representation as l_representation then
					new_response_get_400 (req, res, l_representation)
				end
			end
		end

	new_response_unauthorized(req: WSF_REQUEST; res: WSF_RESPONSE)
				-- Generate a Reponse based on the Media Type
		local
			h: HTTP_HEADER
			l_msg: STRING
			hdate: HTTP_DATE
		do
			create h.make
			create l_msg.make_from_string ("Unauthorized")
			h.put_content_type ("application/vnd.collection+json")
			h.put_content_length (l_msg.count)
			if attached media_variants.vary_header_value as l_vary then
				h.put_header_key_value ("Vary", l_vary)
			end
			if attached req.request_time as time then
				create hdate.make_from_date_time (time)
				h.add_header ("Date:" + hdate.rfc1123_string)
			end
			res.set_status_code ({HTTP_STATUS_CODE}.unauthorized)
			res.put_header_text (h.string)
			res.put_string (l_msg)
		end


feature -- Response

	new_response_get (req: WSF_REQUEST; res: WSF_RESPONSE; output: STRING)
		local
			h: HTTP_HEADER
			l_msg: STRING
			hdate: HTTP_DATE
		do
			create h.make
			create l_msg.make_from_string (output)
			h.put_content_type ("application/vnd.collection+json")
			h.put_content_length (l_msg.count)
			if attached media_variants.vary_header_value as l_vary then
				h.put_header_key_value ("Vary",l_vary)
			end
			if attached req.request_time as time then
				create hdate.make_from_date_time (time)
				h.add_header ("Date:" + hdate.rfc1123_string)
			end
			res.set_status_code ({HTTP_STATUS_CODE}.ok)
			res.put_header_text (h.string)
			res.put_string (l_msg)
		end

	new_response_get_404 (req: WSF_REQUEST; res: WSF_RESPONSE; output: STRING)
		local
			h: HTTP_HEADER
			l_msg: STRING
			hdate: HTTP_DATE
		do
			fixme ("Refactor code and create a simple abstraction to send messages")
			create h.make
			create l_msg.make_from_string (output)
			h.put_content_type ("application/vnd.collection+json")
			h.put_content_length (l_msg.count)
			if attached media_variants.vary_header_value as l_vary then
				h.put_header_key_value ("Vary", l_vary)
			end
			if attached req.request_time as time then
				create hdate.make_from_date_time (time)
				h.add_header ("Date:" + hdate.rfc1123_string)
			end
			res.set_status_code ({HTTP_STATUS_CODE}.not_found)
			res.put_header_text (h.string)
			res.put_string (l_msg)
		end

	new_response_get_400 (req: WSF_REQUEST; res: WSF_RESPONSE; output: STRING)
		local
			h: HTTP_HEADER
			l_msg: STRING
			hdate: HTTP_DATE
		do
			fixme ("Refactor code and create a simple abstraction to send messages")
			create h.make
			create l_msg.make_from_string (output)
			h.put_content_type ("application/vnd.collection+json")
			h.put_content_length (l_msg.count)
			if attached media_variants.vary_header_value as l_vary then
				h.put_header_key_value ("Vary", l_vary)
			end
			if attached req.request_time as time then
				create hdate.make_from_date_time (time)
				h.add_header ("Date:" + hdate.rfc1123_string)
			end
			res.set_status_code ({HTTP_STATUS_CODE}.bad_request)
			res.put_header_text (h.string)
			res.put_string (l_msg)
		end

	new_response_access_denied (req: WSF_REQUEST; res: WSF_RESPONSE; output: STRING)
		local
			h: HTTP_HEADER
			l_msg: STRING
			hdate: HTTP_DATE
		do
			create h.make
			create l_msg.make_from_string (output)
			h.put_content_type ("application/vnd.collection+json")
			h.put_content_length (l_msg.count)
			if attached media_variants.vary_header_value as l_vary then
				h.put_header_key_value ("Vary", l_vary)
			end
			if attached req.request_time as time then
				create hdate.make_from_date_time (time)
				h.add_header ("Date:" + hdate.rfc1123_string)
			end
			res.set_status_code ({HTTP_STATUS_CODE}.unauthorized)
			res.put_header_text (h.string)
			res.put_string (l_msg)
		end


	new_response_authenticate (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- Handle forbidden.
		local
			h: HTTP_HEADER
		do
			create h.make
			h.put_content_type ("application/vnd.collection+json")
			h.put_current_date
			h.put_header_key_value ({HTTP_HEADER_NAMES}.header_www_authenticate, "Basic realm=%"User%"")
			res.set_status_code ({HTTP_STATUS_CODE}.unauthorized)
			res.put_header_text (h.string)
		end

end
