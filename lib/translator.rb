
class Translator

	def initialize
		@renderer = Redcarpet::Render::HTML.new :with_toc_data => true
		@parser = Redcarpet::Markdown.new @renderer, :autolink => true, :fenced_code_blocks => true, :no_intra_emphasis => true, :superscript => true
	end
	
	def translate_file(source_file, destination_file, template_name)
		config_yaml = '', markdown = '', merge_hash = {}
		
		source_sections = File.open(source_file, "r") {|f| f.read }.split("#####")
		
		if source_sections.length > 1
			config_yaml, markdown = source_sections
		else
			markdown = source_sections[0]
		end
		
		if config_yaml
			begin
				merge_hash = YAML::load(config_yaml)
			rescue
				merge_hash = Hash.new
			end
		else
			merge_hash = Hash.new
		end
			
		merge_hash['POST_TAGS'] = merge_hash['POST_TAGS'].split(',').map {|t| "<li>#{t.strip}</li>" }.join if merge_hash['POST_TAGS']
		
		merge_hash['POST_CONTENT'] = @parser.render(markdown)
		
		content_html = HtmlMerger.merge(template_name, merge_hash)

		File.open(destination_file, "w") {|f| f.write(content_html) }
	end
	
	def translate_directory(source_directory, destination_directory)
		Dir.chdir(source_directory) do
			Dir.glob("**.{md,markdown}").each do |f| 
				source = source_directory.chomp('/') + '/' + f
				destination = destination_directory.chomp('/') + '/' + f.sub(/\.(md|markdown)$/, '.html')
				
				template_name = source_directory.split('/').last
				self.translate_file(source, destination, template_name)
			end
		end
	end
end