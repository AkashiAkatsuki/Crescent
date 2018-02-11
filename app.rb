require 'sinatra'
require './core.rb'
require 'json'

before do
end

post '/api/talk' do
  content_type 'application/json'
  return { text: params[:text] }.to_json
end
