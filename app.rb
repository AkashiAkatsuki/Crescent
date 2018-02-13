# coding: utf-8
require 'sinatra'
require './core.rb'
require 'json'
require 'pry'

before do
  @core = Core.new
end

post '/api/talk' do
  content_type 'application/json'
  return { text: '無理...' }.to_json unless params.key? :text
  return { text: '誰？'}.to_json unless params.key?(:name) && params.key?(:screen_name) 
  { text: @core.response(params[:text], member: params[:name], screen_name: params[:screen_name]) }.to_json
end
