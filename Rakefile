require 'redcarpet'
require 'yaml'

require './lib/doc_merger'
require './lib/translator'
require './lib/yaml_facade'
require './lib/post_saver'

BUILD_ROOT = Dir.pwd
POSTS_DIR = BUILD_ROOT + '/../posts'
TEMPLATES_DIR = BUILD_ROOT + '/../templates'
OUTPUT_DIR = BUILD_ROOT + '/../html'

directory POSTS_DIR
directory TEMPLATES_DIR
directory "#{OUTPUT_DIR}/posts"
directory "#{OUTPUT_DIR}/posts/partials"

task :clear_output_path do
	sh "rm -rf '#{OUTPUT_DIR}'"
	sh "mkdir '#{OUTPUT_DIR}'"
end

task :assemble_posts => [POSTS_DIR] do
  all_posts = YamlFacade.join_directory POSTS_DIR
  
  File.open("#{BUILD_ROOT}/posts.yml", "w") {|f| f.write(all_posts)}
end

task :merge_posts_to_complete_html => [:clear_output_path, "#{OUTPUT_DIR}/posts", :assemble_posts] do
	merger = DocMerger.new
	post_dir = "#{OUTPUT_DIR}/posts"
	
	YamlFacade.load_documents("#{BUILD_ROOT}/posts.yml").each do |post|
		post['content'] = merger.merge 'posts', post
		
		post_html = merger.merge 'page', post
		
		PostSaver.save(post_html, post_dir, post['title'])
	end
	
end

task :merge_posts_to_partial_html => [:clear_output_path, "#{OUTPUT_DIR}/posts/partials", :assemble_posts] do
	merger = DocMerger.new
	post_dir = "#{OUTPUT_DIR}/posts/partials"
	
	YamlFacade.load_documents("#{BUILD_ROOT}/posts.yml").each do |post|
		post_html = merger.merge 'posts', post

		puts post_html
		
		PostSaver.save(post_html, post_dir, post['title'])
	end
end
