class PostAggregator

	def initialize
		@ps = PageSaver.new
		@merger = DocMerger.new
	end

	def most_recent(count = 1)

	  @posts = YamlFacade.load_documents("posts.yml").sort {|a,b| DateTime.parse(b['pub-date']) <=> DateTime.parse(a['pub-date']) } unless @posts
	  
	  count == 1 ? @posts.first : @posts.first(count)
	end
	
	def aggregate_most_recent(count, post_templates)
		content = ''
		
		most_recent(count).each do |post|

			# Store some calculated data
			post['rss-pub-date'] = Date.parse(post['pub-date']).rfc2822
			post['rel-link'] = "/posts/#{ @ps.get_file_name(post['title']) }"
			post['abs-link'] = "#{ BASE_URL }#{ post['rel-link'] }"
			
			# Merge & append
			content += @merger.merge post, post_templates
		end
	
		content

	end
	
end