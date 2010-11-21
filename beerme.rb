require 'rubygems'
require 'sinatra'
require 'rest_client'
require 'yaml'
require 'json'
require 'mechanize'
require 'hpricot'

class SMS
  
  def initialize
    @config = YAML.load_file 'cloudvox_config.yml'
    @cloudvox_api = RestClient::Resource.new("https://#{@config['domain']}.cloudvox.com", :user => "#{@config['user']}", :password => "#{@config['password']}")
  end
  
  def send to, from, message
    @cloudvox_api["/api/v1/applications/#{@config['application_id']}/sms"].post :to => to, 
                                                                                :from => from,
                                                                                :message => message
  end                                                                                                                                                                                      
end

class BAProfile
  
  def initialize name
    @name = name
  end
  
  def googlesearch
    searchstring = @name.gsub(" ", "+")
    response = RestClient.get("http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=site:beeradvocate.com+#{searchstring}")
    link = JSON.parse(response.body)['responseData']['results'].slice(0)
    return link['url']
  end
  
  def barating 
    link = googlesearch
    
    agent = Mechanize.new
    ba_profile = agent.get(link)
    doc = Hpricot(ba_profile.body)
    {:overall => doc.search('.BAscore_big').first.inner_text.strip(),
     :bros => doc.search('.BAscore_big').last.inner_text.strip(),
     :title => ba_profile.title.split("-")[0],
     :link => link}
  end  

end  
      
post '/sms' do
  content_type :json
  
puts "Message:" + params['message']
puts "To:" + params['to']
puts "From:" + params['from']

beer = BAProfile.new "#{params['message']}"
results = beer.barating 

message = "#{results[:title]} - Overall: #{results[:overall]} The Bros: #{results[:bros]} #{results[:link]}"
puts message

outgoing = SMS.new
outgoing.send params['from'], params['to'], message

end      