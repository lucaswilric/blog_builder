require 'html/pipeline'

class HPTranslator

	def initialize(context)
    @pipeline = HTML::Pipeline.new [
      HTML::Pipeline::MarkdownFilter,
      HTML::Pipeline::AutolinkFilter,
      HTML::Pipeline::SyntaxHighlightFilter,
      HTML::Pipeline::EmojiFilter
    ], context
	end
	
	def translate(text)
    @pipeline.call(text)[:output].to_s
	end
	
end
