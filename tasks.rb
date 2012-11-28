require 'redcarpet'
require 'yaml'

require 'doc_merger'
require 'translator'
require 'yaml_facade'
require 'page_saver'
require 'post_aggregator'
require 'cfg'

_BUILD_ROOT = ''
_POSTS_DIR = 'posts'
_TEMPLATES_DIR = 'templates'
_OUTPUT_DIR = 'public'

directory _POSTS_DIR
directory "img"
directory _TEMPLATES_DIR
directory "#{_OUTPUT_DIR}/img"
directory "#{_OUTPUT_DIR}/posts"
directory "#{_OUTPUT_DIR}/posts/partials"

desc "The default task: build the blog using default parameters."
task :default => [:initialise, :clear_output_path, :assemble_posts, :partial_html, :complete_html, :front_page, :rss, :archive, :static_files] do
	# Nothing
end

desc 'Build the blog. This task lets you specify the root directory and config file.'
task :do_everything, :pwd, :config do |t, args|
	args.with_defaults(:pwd => Rake.original_dir.sub(/\/blog_builder$/, ''), :config => "#{ Rake.original_dir }/config.yml")

	Rake::Task[:initialise].invoke(args[:pwd], args[:config])
	
	Rake::Task[:default].invoke
end

desc 'Set the build parameters to those given, and load the config from the given file (or config.yml)'
task :initialise, :pwd, :config do |t, args|
	args.with_defaults(:pwd => Rake.original_dir.sub(/\/blog_builder$/, ''), :config => "#{ Rake.original_dir }/config.yml")
	_BUILD_ROOT = args[:pwd]
	
	Cfg.load(args[:config])
	
	puts "Build root: #{_BUILD_ROOT}"
	
	Dir.chdir(_BUILD_ROOT)
end

desc 'Clean the output directory so we have a clean build.'
task :clear_output_path => [:initialise] do
	sh "rm -rf '#{_OUTPUT_DIR}'"
	sh "mkdir '#{_OUTPUT_DIR}'"
end

desc 'Move the static files from the templates and posts directories to the output directory.'
task :static_files => [:initialise, "img", "#{ _OUTPUT_DIR }/img"] do
	cp_r "img/.", "#{ _OUTPUT_DIR }/img"
	cp_r "#{ _TEMPLATES_DIR }/static/.", "#{ _OUTPUT_DIR }"
end

desc 'Assemble all the YAML files from the posts directory into one big YAML document to minimise I/O.'
task :assemble_posts => [:initialise, _POSTS_DIR] do
  all_posts = YamlFacade.join_directory _POSTS_DIR
  
  File.open("posts.yml", "w") {|f| f.write(all_posts)}
end

desc 'Generate the front page, which shows the 10 newest posts.'
task :front_page => [:initialise, :clear_output_path, :assemble_posts, :complete_html] do
	pa = PostAggregator.new
	
	content = pa.aggregate_most_recent(10, ['posts'])
	
	page = { 
		'blog_url' => Cfg.setting('blog-url'),
		'blog_title' => Cfg.setting('blog-title'),
		'title' => Cfg.setting('blog-title'),
		'content' => content 
	}
	
	page_html = DocMerger.new(_TEMPLATES_DIR).merge page, ['page']
	
	PageSaver.new.save(page_html, _OUTPUT_DIR, 'index')
end	

desc 'Generate the RSS feed, which includes the 20 newest posts.'
task :rss => [:initialise, :clear_output_path, :assemble_posts, :complete_html] do
	pa = PostAggregator.new

	content = pa.aggregate_most_recent(20, ['posts-rss'])
	
	rss = { 
		'title' => Cfg.setting('blog-title'), 
		'blog_url' => Cfg.setting('blog-url'), 
		'description' => Cfg.setting('blog-tagline'), 
		'content' => content,
		'pub_date' => DateTime.parse(pa.most_recent['pub_date']).rfc2822
	}
	
	page_rss = DocMerger.new(_TEMPLATES_DIR).merge rss, ['page-rss']
	
	PageSaver.new.save(page_rss, _OUTPUT_DIR, 'rss', 'xml')
end

desc 'Generate the archive page, which shows a link to every post.'
task :archive => [:initialise, :clear_output_path, :assemble_posts, :complete_html] do
	pa = PostAggregator.new
	
	content = pa.aggregate_most_recent(99999, ['link'])
	
	archive = {
		'blog_url' => Cfg.setting('blog-url'),
		'title' => "#{ Cfg.setting('blog-title') } - Archive",
		'blog_title' => Cfg.setting('blog-title'),
		'content' => content
	}
	
	archive_page = DocMerger.new(_TEMPLATES_DIR).merge archive, ['archive', 'page']
	
	PageSaver.new.save(archive_page, _OUTPUT_DIR, 'archive')
end

desc 'Generate the pages that display each individual post.'
task :complete_html => [:initialise, :clear_output_path, "#{_OUTPUT_DIR}/posts", :assemble_posts] do
	merger = DocMerger.new(_TEMPLATES_DIR)
	ps = PageSaver.new
	post_dir = "#{_OUTPUT_DIR}/posts"
	
	YamlFacade.load_documents("#{_BUILD_ROOT}/posts.yml").each do |post|
		post['blog_url'] = Cfg.setting('blog-url')
		post['blog_title'] = Cfg.setting('blog-title')
		post['file_name'] = post['file'].sub(/\.yml$/, '')
		post_html = merger.merge post, ['posts', 'page']
		
		ps.save(post_html, post_dir, post['file'].sub(/\.yml$/, ''))
	end
	
end

desc 'Generate the "HTML chunk" for each post - just the HTML, none of the template crap.'
task :partial_html => [:initialise, :clear_output_path, "#{_OUTPUT_DIR}/posts/partials", :assemble_posts] do
	merger = DocMerger.new(_TEMPLATES_DIR)
	ps = PageSaver.new
	post_dir = "#{_OUTPUT_DIR}/posts/partials"
	
	YamlFacade.load_documents("#{_BUILD_ROOT}/posts.yml").each do |post|
		post['file_name'] = post['file'].sub(/\.yml$/, '')
		post_html = merger.merge post, ['posts']
		
		ps.save(post_html, post_dir, post['file'].sub(/\.yml$/, ''))
	end
end
