class DocMerger

	def initialize(templates_dir = 'templates')
		@translator = Translator.new
		@templates_dir = templates_dir
	end

	def merge(hash, wrappers)
		content_text = ''
		
		if hash['markdown']
			merge_templates(hash['markdown']) 
		
			hash['content'] = @translator.translate(hash['markdown'])
		else
			hash['content'] = merge_templates(hash['content'])
		end
			
		wrappers.each do |template_name|
			template = get_template(template_name)
			
			hash['formatted-tags'] = merge_list(hash['tags'], template['tag-element']) if hash['tags']
			
			content_text = merge_hash(template, hash)
			
			hash['content'] = content_text
		end
		
		content_text
	end
	
	def get_template(template_name)
		YamlFacade.load_documents("#{ @templates_dir }/#{template_name}.yml")[0]
	end
	
	def merge_hash(data, hash)
		text = ''
		defaults = {}
		
		if data['content'] == nil
			raise "Template '#{ template_name }' must have a 'content' node."
		else
			text = data['content']
		end
		
		defaults = data['defaults'] if data['defaults']
	
		defaults.merge(hash).each do |key, value|
			puts 'value of #{key} is empty!' if value == nil
			text.gsub! /\[\[#{key}\]\]/, value.to_s
		end
		
		text
	end
	
	def merge_templates(text, stack = [])
		/<<([^>]+)>>/.match(text) do |m|
			template_name, data = m[1].strip.split(' ', 2)
			
			raise "Circular template dependency!! #{ stack.push(template_name).join(' -> ') }" if stack.include? template_name
			
			template_text = merge_hash(get_template(template_name), YAML::load(data))
			
			text.sub! /#{ m[0] }/, merge_templates(template_text, stack << template_name)
		end
		
		text
	end
	
	def merge_list(list, element)
		list.map {|t| "<#{element}>#{t}</#{element}>" }.join
	end
end