require 'redcarpet'
require 'yaml'

require './lib/doc_merger'
require './lib/translator'
require './lib/yaml_facade'
require './lib/page_saver'
require './lib/post_aggregator'

_BUILD_ROOT = ''
_POSTS_DIR = 'posts'
_TEMPLATES_DIR = 'templates'
_OUTPUT_DIR = 'html'

BLOG_TITLE = 'The Grand Experiment'
BASE_URL = 'http://lucasrichter.id.au'
BLOG_TAGLINE = 'The blog of the great adventurer'

directory _POSTS_DIR
directory _TEMPLATES_DIR
directory "#{_OUTPUT_DIR}/posts"
directory "#{_OUTPUT_DIR}/posts/partials"

task :default => [:initialise, :clear_output_path, :assemble_posts, :partial_html, :complete_html, :front_page, :rss, :archive] do
	# Nothing
end

task :do_everything, :pwd do |t, args|
	args.with_defaults(:pwd => Dir.pwd.sub(/\/blog_builder$/, ''))
	_BUILD_ROOT = args[:pwd]
	
	puts "Build root: #{_BUILD_ROOT}"
	
	Dir.chdir(_BUILD_ROOT) do
		Rake::Task[:default].invoke
	end
end

task :initialise do
#	_POSTS_DIR = _BUILD_ROOT + '/posts'
#	_TEMPLATES_DIR = _BUILD_ROOT + '/templates'
#	_OUTPUT_DIR = _BUILD_ROOT + '/html'
end

task :clear_output_path => [:initialise] do
	sh "rm -rf '#{_OUTPUT_DIR}'"
	sh "mkdir '#{_OUTPUT_DIR}'"
end

task :assemble_posts => [:initialise, _POSTS_DIR] do
  all_posts = YamlFacade.join_directory _POSTS_DIR
  
  File.open("posts.yml", "w") {|f| f.write(all_posts)}
end

task :front_page => [:initialise, :clear_output_path, :assemble_posts, :complete_html] do
	pa = PostAggregator.new
	
	content = pa.aggregate_most_recent(10, ['posts'])
	
	page = { 
		'title' => BLOG_TITLE, 
		'content' => content 
	}
	
	page_html = DocMerger.new(_TEMPLATES_DIR).merge page, ['page']
	
	PageSaver.new.save(page_html, _OUTPUT_DIR, 'index')
end	

task :rss => [:initialise, :clear_output_path, :assemble_posts, :complete_html] do
	pa = PostAggregator.new

	content = pa.aggregate_most_recent(20, ['posts-rss'])
	
	rss = { 
		'title' => BLOG_TITLE, 
		'link' => BASE_URL, 
		'description' => BLOG_TAGLINE, 
		'content' => content,
		'pub-date' => Date.parse(pa.most_recent['pub-date']).rfc2822
	}
	
	page_rss = DocMerger.new(_TEMPLATES_DIR).merge rss, ['page-rss']
	
	PageSaver.new.save(page_rss, _OUTPUT_DIR, 'rss', 'xml')
end

task :archive => [:initialise, :clear_output_path, :assemble_posts, :complete_html] do
	pa = PostAggregator.new
	
	content = pa.aggregate_most_recent(99999, ['link'])
	
	archive = {
		'title' => "#{ BLOG_TITLE } - Archive",
		'content' => content
	}
	
	archive_page = DocMerger.new(_TEMPLATES_DIR).merge archive, ['archive', 'page']
	
	PageSaver.new.save(archive_page, _OUTPUT_DIR, 'archive')
end

task :complete_html => [:initialise, :clear_output_path, "#{_OUTPUT_DIR}/posts", :assemble_posts] do
	merger = DocMerger.new(_TEMPLATES_DIR)
	ps = PageSaver.new
	post_dir = "#{_OUTPUT_DIR}/posts"
	
	YamlFacade.load_documents("#{_BUILD_ROOT}/posts.yml").each do |post|
		post_html = merger.merge post, ['posts', 'page']
		
		ps.save(post_html, post_dir, post['title'])
	end
	
end

task :partial_html => [:initialise, :clear_output_path, "#{_OUTPUT_DIR}/posts/partials", :assemble_posts] do
	merger = DocMerger.new(_TEMPLATES_DIR)
	ps = PageSaver.new
	post_dir = "#{_OUTPUT_DIR}/posts/partials"
	
	YamlFacade.load_documents("#{_BUILD_ROOT}/posts.yml").each do |post|
		post_html = merger.merge post, ['posts']
		
		ps.save(post_html, post_dir, post['title'])
	end
end
