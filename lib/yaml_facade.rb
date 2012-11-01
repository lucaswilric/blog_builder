class YamlFacade

  Boundary = "---"
  
  def self.join_directory(dir)
    all_posts = ""
      
    Dir.chdir(dir) do
      Dir.glob("**.{yml}").each do |file| 
        
        yaml = File.open(file, "r") {|f| f.read }
        yaml.sub!(/\A(#{Boundary} *\n*)/, '')
        yaml = "file: #{file}\n" + yaml
        
        all_posts = join_documents all_posts, yaml
      end
    end
    
    all_posts
  end
  
  def self.join_documents(first, second)
    return first unless second
  
    second = "#{ Boundary }\n#{ second }" unless second.start_with? Boundary
    second += "\n" unless second.end_with? "\n"
    
    first.sub(/(^#{Boundary} *\n*)*\Z/, '') + second
  end
  
  def self.load_documents(file_name)
    docs = []
    
    docs_text = File.open(file_name) {|f| f.read }

    YAML::load_documents(docs_text) do |yml|
      docs << yml
    end
    
    docs.compact
  end
end