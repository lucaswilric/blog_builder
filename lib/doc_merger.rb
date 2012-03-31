class HtmlMerger
	def self.merge(template_name, merge_hash)
		content_text = File.open("#{BUILD_ROOT}/templates/#{template_name}.html", "r") {|f| f.read }
		
		merge_hash.each do |key, value|
			content_text = content_text.gsub(/\[\[#{key}\]\]/, value)
		end
		
		content_text
	end
end