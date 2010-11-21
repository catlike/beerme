require 'yaml'
require 'rest_client'


class SMS
  
  def initialize
    @config = YAML.load_file 'config/cloudvox_config.yml'
    @cloudvox_api = RestClient::Resource.new("https://#{@config['domain']}.cloudvox.com", :user => "#{@config['user']}", :password => "#{@config['password']}")
  end
  
  def send to, from, message
    @cloudvox_api["/api/v1/applications/#{@config['application_id']}/sms"].post :to => to, 
                                                                                :from => from,
                                                                                :message => message
  end                                                                                                                                                                                      
end