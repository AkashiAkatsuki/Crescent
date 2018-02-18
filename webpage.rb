require 'sinatra'
require 'kaminari/activerecord'
require './dictionary.rb'
require 'pry'

class WebPage < Sinatra::Base
  before do
    @dic = Dictionary.new
  end
  
  get '/' do
    erb :index
  end

  get '/words/:page' do
    @words = Word.page(params[:page]).per(100)
    erb :words
  end
end
