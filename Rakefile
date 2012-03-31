require 'redcarpet'
require 'yaml'

require './lib/doc_merger'
require './lib/translator'
require './lib/yaml_facade'
require './lib/page_saver'
require './lib/post_aggregator'

BUILD_ROOT = Dir.pwd
POSTS_DIR = BUILD_ROOT + '/../posts'
TEMPLATES_DIR = BUILD_ROOT + '/../templates'
OUTPUT_DIR = BUILD_ROOT + '/../html'

BLOG_TITLE = 'The Grand Experiment'
BASE_URL = 'http://lucasrichter.id.au'
BLOG_TAGLINE = 'The blog of the great adventurer'

directory POSTS_DIR
directory TEMPLATES_DIR
directory "#{OUTPUT_DIR}/posts"
directory "#{OUTPUT_DIR}/posts/partials"

task :default => [:clear_output_path, :front_page, :rss, :archive, :complete_html, :partial_html] do
 # Nothing
end

task :clear_output_path do
	sh "rm -rf '#{OUTPUT_DIR}'"
	sh "mkdir '#{OUTPUT_DIR}'"
end

task :assemble_posts => [POSTS_DIR] do
  all_posts = YamlFacade.join_directory POSTS_DIR
  
  File.open("#{BUILD_ROOT}/posts.yml", "w") {|f| f.write(all_posts)}
end

task :front_page => [:clear_output_path, :assemble_posts, :complete_html] do
	pa = PostAggregator.new
	
	content = pa.aggregate_most_recent(10, ['posts'])
	
	page = { 
		'title' => BLOG_TITLE, 
		'content' => content 
	}
	
	page_html = DocMerger.new.merge page, ['page']
	
	PageSaver.new.save(page_html, OUTPUT_DIR, 'index')
end	

task :rss => [:clear_output_path, :assemble_posts, :complete_html] do
	pa = PostAggregator.new

	content = pa.aggregate_most_recent(20, ['posts-rss'])
	
	rss = { 
		'title' => BLOG_TITLE, 
		'link' => BASE_URL, 
		'description' => BLOG_TAGLINE, 
		'content' => content,
		'pub-date' => Date.parse(pa.most_recent['pub-date']).rfc2822
	}
	
	page_rss = DocMerger.new.merge rss, ['page-rss']
	
	PageSaver.new.save(page_rss, OUTPUT_DIR, 'rss', 'xml')
end

task :archive => [:clear_output_path, :assemble_posts, :complete_html] do
	pa = PostAggregator.new
	
	content = pa.aggregate_most_recent(99999, ['link'])
	
	archive = {
		'title' => "#{ BLOG_TITLE } - Archive",
		'content' => content
	}
	
	archive_page = DocMerger.new.merge archive, ['archive', 'page']
	
	PageSaver.new.save(archive_page, OUTPUT_DIR, 'archive')
end

task :complete_html => [:clear_output_path, "#{OUTPUT_DIR}/posts", :assemble_posts] do
	merger = DocMerger.new
	ps = PageSaver.new
	post_dir = "#{OUTPUT_DIR}/posts"
	
	YamlFacade.load_documents("#{BUILD_ROOT}/posts.yml").each do |post|
		post_html = merger.merge post, ['posts', 'page']
		
		ps.save(post_html, post_dir, post['title'])
	end
	
end

task :partial_html => [:clear_output_path, "#{OUTPUT_DIR}/posts/partials", :assemble_posts] do
	merger = DocMerger.new
	ps = PageSaver.new
	post_dir = "#{OUTPUT_DIR}/posts/partials"
	
	YamlFacade.load_documents("#{BUILD_ROOT}/posts.yml").each do |post|
		post_html = merger.merge post, ['posts']
		
		ps.save(post_html, post_dir, post['title'])
	end
end
