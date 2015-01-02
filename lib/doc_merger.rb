require 'erb'
require 'pygments'

class DocMerger

  def initialize(templates_dir = 'templates')
    @translator = HPTranslator.new(asset_root: 'http://assets.github.com/images/icons/')
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
