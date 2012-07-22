require 'erb'

class DocMerger

	def initialize(templates_dir = 'templates')
		@translator = Translator.new
		@tl = TemplateLoader.new(templates_dir)
	end

	def merge(hash, wrappers)
		content_text = ''
	
		content_key = hash['markdown'] ? 'markdown' : 'content'
		
		hash[content_key] = merge_text(hash[content_key], hash)
		translate_markdown hash
	
		wrappers.each do |template_name|
			template = @tl.get_template(template_name)
			
			hash['formatted_tags'] = merge_list(hash['tags'], template['tag_element']) if hash['tags']

			content_text = hash['content'] = merge_text(template['html'], (template['defaults'] || {}).merge(hash))
		end
		
		merge_text(content_text, hash)
	end
	
	def merge_list(list, element)
		list.map {|t| "<#{element}>#{t}</#{element}>" }.join
	end
	
	def merge_text(text, hash)
		TemplateRenderer.new(hash, @tl).render(text)
	end
	
	def translate_markdown(hash)
		hash['content'] = @translator.translate(hash['markdown']) if hash['markdown']
		#.gsub('&lt;%', '<%').gsub('%&gt;', '%>').gsub('<%%', '&lt;%').gsub('%%>', '%&gt;')
	end
end

class TemplateLoader
  def initialize(templates_dir)
    @templates_dir = templates_dir
  end
  	
  def get_template(template_name)
	YamlFacade.load_documents("#{ @templates_dir }/#{template_name}.yml")[0]
  end
end

class TemplateRenderer
  def initialize(hash, template_loader)
    @hash = hash
    @tl = template_loader
  end
  
  def method_missing(meth, *args, &block)
  	if args.length > 0
  	  return render_template meth.to_s, args[0]
  	end
  
  	return @hash[meth.to_s] unless @hash[meth.to_s] == nil

  	raise "There's no '#{ meth }' here!"
  end
  
  def render(erb)
  	ERB.new(erb).result(binding)
  end
  
  def render_template(name, hash, stack = [])
	raise "Circular template dependency!! #{ stack.push(name).join(' -> ') }" if stack.include? name
	
	h2 = {}
	hash.each {|k,v| h2[k.to_s] = v }
	hash.merge! h2
	
	t = @tl.get_template(name)
	TemplateRenderer.new(t['defaults'].merge(hash), @tl).render(t['html'])
  end
end