class PostAggregator

	def initialize
		@ps = PageSaver.new
		@merger = DocMerger.new
	end

	def most_recent(count = 1)

	  @posts = YamlFacade.load_documents("posts.yml").sort {|a,b| DateTime.parse(b['pub_date']) <=> DateTime.parse(a['pub_date']) } unless @posts
	  
	  count == 1 ? @posts.first : @posts.first(count)
	end
	
	def aggregate_most_recent(count, post_templates)
		content = []
		
		most_recent(count).each do |post|

			# Store some calculated data
			pub_date = DateTime.parse(post['pub_date']).rfc2822
			post['rss_pub_date'] = pub_date[0..pub_date.length-10]
			post['file_name'] = @ps.get_file_name(post['title'], '')
			post['rel_link'] = "/posts/#{ post['file_name'] }.html"
			post['abs_link'] = "#{ Cfg.setting('blog-url') }#{ post['rel_link'] }"
			
			if post['enclosure'] and not /^https?:\/\//.match(post['enclosure'])
			    post['abs_enclosure'] = "#{ Cfg.setting('blog-url') }/#{ post['enclosure'] }"
			else
			    post['abs_enclosure'] = post['enclosure'] || ''
			end
  		
			# Merge & append
			content << @merger.merge(post, post_templates)
		end
	
		content.join "\n"

	end
	
end