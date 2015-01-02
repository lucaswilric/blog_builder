class TemplateLoader
  def initialize(templates_dir)
    @templates_dir = templates_dir
  end
    
  def get_template(template_name)
  YamlFacade.load_documents("#{ @templates_dir }/#{template_name}.yml")[0]
  end
end

