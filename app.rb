require 'sinatra'

get '/' do
  "This is the home page."
end

get '/success' do
  "Your payment has processed successfully."
end

post '/pay' do
  puts "The data sent to the /pay POST route is:"
  p params
  redirect '/success'
end
