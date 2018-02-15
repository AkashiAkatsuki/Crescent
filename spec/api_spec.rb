# coding: utf-8
require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'json'

set :environment, :test

describe 'POST /api/talk' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  context "こんにちは" do
    before do
      post '/api/talk', {text: 'こんにちは'}
      @json = JSON.parse(last_response.body)
    end

    it '文字列で返事が返ってくるか' do
      p @json['text']
      expect(@json['text'].is_a? String).to be_true
    end
  end
end
