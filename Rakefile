require 'redcarpet'
require 'yaml'

require './lib/html_merger'
require './lib/translator'

BUILD_ROOT = Dir.pwd

directory "html/posts"
directory "html/posts/partials"

task :translate_posts => ["html/posts/partials"] do
	src_dir = BUILD_ROOT + '/posts'
	dest_dir = BUILD_ROOT + '/html/posts/partials'
	
	Translator.new.translate_directory(src_dir, dest_dir)
end

task :inject_posts_into_templates => ["html/posts/partials", :translate_posts] do
	template_text = File.open(BUILD_ROOT + "/templates/layout.html", "r") {|f| f.read }
	
	Dir.chdir 'html/posts/partials' do
		Dir.glob("*.html").each do |file|		
			merge_hash = Hash.new
			merge_hash['PAGE_TITLE'] = file.sub(/.html$/, '').gsub(/_/, ' ').capitalize
			merge_hash['PAGE_CONTENT'] = File.open(file, "r") {|f| f.read }
			
			complete_post = HtmlMerger.merge('layout', merge_hash)
			
			File.open('../'+file, "w") {|f| f.write complete_post }
		end
	end
end