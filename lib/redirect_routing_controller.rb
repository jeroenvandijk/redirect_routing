class RedirectRoutingController < ActionController::Base
  def redirect
		options = params[:args].extract_options!
		status = options.delete(:permanent) == true ? :moved_permanently : 302

		# Forward params
		keys_to_ignore = %W(args action controller permanent)
		new_params = params.reject { |key, _| keys_to_ignore.include?(key) }
		
		# controller and/or action are defined use 
		url_options = params[:args].first || options

		# When url_options is a string we should apply pattern matching
		if url_options.is_a?(String)
			# Add found params to url by search for symbols in the url
			params.each_pair do |key, value| 
				if url_options =~ /:#{key.to_s}/
					url_options.gsub!(/:#{key.to_s}/, value.to_s)
					# also ignore the declared params in the path
					new_params.delete(key)
				end
			end
			# Remove all left symbols in the string
			url_options.gsub!(/\/:.*/, "")
					
			# forward params doesn't work with arrays
			param_pairs = []
			new_params.each_pair do |key, value| 
				if value.is_a?(String)
					param_pairs << "#{key}=#{value}"
				elsif value.is_a?(Array)
					value.each {|v| param_pairs << "#{key}[]=#{v}" }
				elsif value.is_a?(Hash)
					value.each_pair {|k,v| param_pairs << "#{key}[#{k}]=#{v}" }
				end
			end
			url_options += "?" + param_pairs.join("&") unless param_pairs.empty?

		elsif url_options.is_a?(Hash)
			# Forward all other params
			url_options.reverse_merge!(new_params)
		end

    redirect_to url_options, :status => status
  end
end