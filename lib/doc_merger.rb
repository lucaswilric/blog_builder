class DocMerger

	def initialize
		@translator = Translator.new
	end

	def merge(hash, templates)
		content_text = ''
		
		hash['content'] = @translator.translate(hash['markdown']) if hash['markdown']
			
		templates.each do |template_name|
			template = YamlFacade.load_documents("#{TEMPLATES_DIR}/#{template_name}.yml")[0]
			
			content_text = template['content']
			
			hash['formatted-tags'] = merge_list(hash['tags'], template['tag-element']) if hash['tags']
			
			hash.each do |key, value|
				puts 'value of #{key} is empty!' unless value
				content_text = content_text.gsub(/\[\[#{key}\]\]/, value.to_s)
			end
		end
		
		content_text
	end
	
	def merge_list(list, element)
		list.map {|t| "<#{element}>#{t}</#{element}>" }.join
	end
end