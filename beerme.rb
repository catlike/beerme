require 'rubygems'
require 'sinatra'
require 'lib'
       
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