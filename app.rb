require 'sinatra'
require './core.rb'
require 'json'

before do
  @core = Core.new
end

post '/api/talk' do
  content_type 'application/json'
  return { text: @core.response(params[:text]) }.to_json
end
