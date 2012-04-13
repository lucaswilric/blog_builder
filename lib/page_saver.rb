class PageSaver
	def initialize(extension = "html")
		@extension = extension
	end

	def save(content, dir, title, extension = @extension)
		file_path = "#{ dir }/#{ get_file_name(title, extension) }"
	
		raise "'#{ file_path }' already exists!" if File.exists?(file_path)
		File.open(file_path, "w") {|f| f.write content }
	end
	
	def get_file_name(title, extension = @extension)
		title.gsub(/ /, '-').gsub(/[^A-Za-z0-9_-]/, '').downcase + ([nil, ''].include?(extension) ? '' : '.' + extension)
	end
end