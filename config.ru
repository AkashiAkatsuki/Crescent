require 'sinatra'
require './api.rb'
require './webpage.rb'
require './core.rb'
require './twitter.rb'

class App < Sinatra::Base
  ROUTES = {
     "/" => WebPage,
     "/api" => API
  }
end

Thread.new do
  TwitterManager.new(Core.new).stream_start
end
run Rack::URLMap.new(App::ROUTES)
