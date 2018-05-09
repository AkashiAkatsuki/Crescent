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
      w = Word.where('name like ?', '%' + params[:search] + '%')
    else
      w = Word.all
    end
    order = params[:order]
    order = 'id' if order.nil?
    order = 'id' unless [
      'id', 'id desc',
      'name', 'name desc',
      'category', 'category desc',
      'value', 'value desc'].include?(order)
    @words = w.order(order).page(params[:page]).per(100)
    @category_hash = Dictionary::CATEGORY_HASH.invert
    erb :words
  end
end
