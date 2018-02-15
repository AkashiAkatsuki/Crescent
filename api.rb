# coding: utf-8
require 'sinatra'
require './core.rb'
require 'json'

class API < Sinatra::Base
  before do
    @core = Core.new
  end

  get '/name' do
    content_type 'application/json'
    { name: @core.name }.to_json
  end

  get '/word/:id' do
    content_type 'application/json'
    Word.find(params[:id]).to_json
  end

  post '/talk' do
    content_type 'application/json'
    return { text: '無理...' }.to_json unless params.key? :text
    return { text: '誰？'}.to_json unless params.key?(:name) && params.key?(:screen_name)
    { text: @core.response(params[:text], member: params[:name], screen_name: params[:screen_name]) }.to_json
  end
end
