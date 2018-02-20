# coding: utf-8
require_relative '../api.rb'
require 'rspec'
require 'rspec/json_matcher'
require 'rack/test'
require 'json'
require 'pry'

set :environment, :test
include Rack::Test::Methods
include RSpec::JsonMatcher

def app
  API
end

def response_json
  JSON.parse(last_response.body)
end

describe 'GET /name' do
  before do
    get '/name'
  end

  it '名前が返却される' do
    expect(last_response.body).to be_json_as({ name: String })
  end
end

describe 'GET /word/:id' do
  context 'id:1' do
    before do
      get '/word/1'
    end

    it '単語が返却される' do
      expect(last_response.body).to be_json_as({
        id:       Integer,
        name:     String,
        category: Integer,
        value:    Float
      })
    end
  end
end

describe 'POST /talk' do
  context "こんにちは" do
    before do
      post '/talk', {text: 'こんにちは'}
    end

    it '文字列で返事が返ってくるか' do
      p response_json['text']
      expect(last_response.body).to be_json_as({ text: String })
    end
  end
end
