class PostSaver
	def self.save(content, dir, title)
		file_name = title.gsub(/ /, '-').gsub(/[^A-Za-z0-9_-]/, '').downcase + ".html"
		file_path = "#{dir}/#{file_name}"
	
		raise "'#{file_path}' already exists!" if File.exists?(file_path)
		File.open(file_path, "w") {|f| f.write content }
	end
end