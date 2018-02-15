require 'sinatra'
require './api.rb'
require './webpage.rb'

class App < Sinatra::Base
  ROUTES = {
     "/" => WebPage,
     "/api" => API
  }
end

run Rack::URLMap.new(App::ROUTES)
