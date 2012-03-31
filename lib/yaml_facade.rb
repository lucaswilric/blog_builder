class YamlFacade

  Boundary = "---\n"
  
  def join_directory(dir)
    all_posts = ""
      
    Dir.chdir(POSTS_DIR) do
      Dir.glob("**.{yml}").each do |file| 
        
        yaml = File.open(file, "r") {|f| f.read }
        
        all_posts = join_documents all_posts, yaml
      end
    end
    
    all_posts
  end
  
  def join_documents(first, second)
    return first unless second
  
    second = Boundary + second unless second.start_with? Boundary
    second += "\n" unless second.end_with? "\n"
    
    first.sub(/(^#{Boundary}*)*\Z/, '') + second
  end
  
  def read_documents(file_name)
    docs = []
    
    docs_text = File.open(file_name) {|f| f.read }

    YAML::load_documents(docs_text) do |yml|
      docs << yml
    end
  end
end