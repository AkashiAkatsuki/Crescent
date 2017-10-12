require 'sinatra/base'

class WebPage < Sinatra::Base

  def self.init(core)
    @@array = Array.new
    @@core = core
  end

  get '/' do
    @name = @@core.name
    @texts = @@array
    erb :index
  end

  post '/send' do
    @@array.push "> " + params['text']
    @@array.push @@core.name + "> " + @@core.response(params['text'])
    @texts = @@array
    erb :index
  end

end
