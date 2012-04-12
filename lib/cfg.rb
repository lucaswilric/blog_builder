class Cfg
  def self.load(filename)
    puts "Loading config from #{filename}."
    @@config = YamlFacade.load_documents(filename)[0]
  end
  
  def self.setting(stg)
    @@config[stg]
  end
end