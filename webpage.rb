require 'sinatra'
require 'kaminari/activerecord'
require 'kaminari/sinatra'
require './dictionary.rb'
require 'pry'

class WebPage < Sinatra::Base
  register Kaminari::Helpers::SinatraHelpers

  get '/' do
    erb :index
  end

  get '/words' do
    if params[:search] then
      @words = Word.where('name like ?', '%' + params[:search] + '%').page(params[:page]).per(100)
    else
      @words = Word.page(params[:page]).per(100)
    end
    @category_hash = Dictionary::CATEGORY_HASH.invert
    erb :words
  end
end
