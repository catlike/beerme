require 'rest_client'
require 'json'
require 'mechanize'
require 'hpricot'

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