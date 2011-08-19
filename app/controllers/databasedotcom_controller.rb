class DatabasedotcomController < ApplicationController
  cattr_accessor :dbdc_client, :sobject_types
  
  protected
  
  def self.dbdc_client
    unless @@dbdc_client
      config = YAML.load_file(File.join(Rails.root, 'config', 'databasedotcom.yml'))
      @@dbdc_client = Databasedotcom::Client.new(config)
      @@dbdc_client.authenticate(:username => config["username"], :password => config["password"])
    end
    
    @@dbdc_client
  end
  
  def self.sobject_types
    unless @@sobject_types
      @@sobject_types = dbdc_client.list_sobjects
    end
  end
  
  def dbdc_client
    self.class.dbdc_client
  end
  
  def sobject_types
    self.class.sobject_types
  end
  
  def self.const_missing(sym)
    if sobject_types.include?(sym.to_s)
      dbdc_client.materialize(sym.to_s)
    else
      super
    end
  end
end
