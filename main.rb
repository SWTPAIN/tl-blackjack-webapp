require 'rubygems'
require 'sinatra'

set :sessions, true


# get '/home' do
#   "Welcome to KaFai's homepage. Testing </br> Next line"
# end

# get '/inline' do
#   "Hey, directly from the action"
# end

# get '/template' do
#   erb :mytemplate
# end

# get '/nested_template' do
#   erb :"/users/profile"
# end

# get '/nothere' do
#   redirect '/inline'
# end

# get '/form' do
#   erb :form
# end

# post '/myaction' do
#   puts params[:username]
# end

get '/index' do
  "This is the index page"
end

get '/template' do
  "This is the template"
  erb :mytemplate
end

get '/nested_template' do
  erb :"/users/profile"
end
