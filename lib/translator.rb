
class Translator

	def initialize
		@renderer = Redcarpet::Render::HTML.new :with_toc_data => true
		@parser = Redcarpet::Markdown.new @renderer, :autolink => true, :fenced_code_blocks => true, :no_intra_emphasis => true, :superscript => true
	end
	
	def translate(text)
		@parser.render(text)
	end
	
end