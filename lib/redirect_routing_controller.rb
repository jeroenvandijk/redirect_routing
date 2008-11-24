class RedirectRoutingController < ActionController::Base
	# Orginal redirect controller didn't support dynamic urls. Furthermore, it wasn't backwards compatible with rails versions < 2.0
	# because of the use of the method extract_options!
  def redirect
		options = extract_options(params[:args]) # extract_options is declared below since it is not incorporated in older versions of rails
		options.delete(:conditions)
    headers["Status"] = options.delete(:permanent) == true ? "301 Moved Permanently" : "302 Moved Temporarily"
		url_options = params[:args].first || options

		# When url_options is a string we should apply pattern matching
		if url_options.is_a?(String)
			# Add found params to url by search for symbols in the url
			params.each_pair { |key, value| url_options.gsub!(/:#{key.to_s}/, value.to_s) }
			# Remove all left symbols in the string
			url_options.gsub!(/\/:.*/, "")
			
		# When url_options is a hash we just add new params
		elsif url_options.is_a?(Hash)
			url_options.reverse_merge!(new_params)
		end

    redirect_to url_options
  end

	private
		# Method adopted from Rails 2.1.2
		# Extracts options from a set of arguments. Removes and returns the last element in the array if it’s a hash, otherwise returns a blank hash. 
		def extract_options(hash)
			hash.last.is_a?(::Hash) ? hash.pop : {}
		end
		
end