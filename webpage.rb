require 'sinatra'
require 'kaminari/activerecord'
require 'kaminari/sinatra'
require './dictionary.rb'
require 'active_support'

class WebPage < Sinatra::Base
  register Kaminari::Helpers::SinatraHelpers

  get '/' do
    erb :index
  end

  get '/words' do
    if params[:search]
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

  get '/friends' do
    if params[:search]
      f = Friend.where('name like ?', '%' + params[:search] + '%')
    else
      f = Friend.all
    end
    order = params[:order]
    order = 'id' if order.nil?
    order = 'id' unless [
      'id', 'id desc',
      'name', 'name desc',
      'screen_name', 'screen_name desc',
      'love', 'love desc'].include?(order)
    @friends = f.order(order).page(params[:page]).per(100)
    erb :friends
  end

  private
  def url_order(order)
    query = { order: order, search: params[:search], page: params[:page] }
    query.reject!{ |k, v| v.nil? }
    p query
    url + '?' + query.map{ |k, v| k.to_s + '=' + v }.join('&')
  end
end
