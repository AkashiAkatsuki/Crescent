# coding: utf-8
require 'bundler'
require './database.rb'
Bundler.require

class Core
  attr_reader :name

  def initialize(name)
    @name = name
    @listener = Listener.new
    @responder = Responder.new
  end

  def response(input, screen_name: "", name: "")
    @listener.listen(input)
    @responder.response(input)
  end

  def listen(input, screen_name: "", name: "")
    @listener.listen(input)
  end

  def speak
    
  end

end


class Listener

  IGNORE_CATEGORY = /BOS|EOS|記号|その他|フィラー/

  def listen(input)
    nouns = Array.new
    Natto::MeCab.new.enum_parse(input).each do |n|
      unless n.feature.split(",").first.match(IGNORE_CATEGORY)
        puts n.surface
        Word.find_or_create_by(name: n.surface) do |word|
          word.category = n.feature.split(",").first
          word.value = 0
        end
      end
    end
  end
  
end


class Responder

  RESPONSE_CATEGORY = /名詞|感動詞/
  
  def response(input)
    nouns = Array.new
    Natto::MeCab.new.enum_parse(input).each do |n|
      nouns << n if n.feature.split(",").first.match(RESPONSE_CATEGORY)
    end
    return "...?" if nouns.empty?
    nouns.sample.surface + "...?"
  end
  
end

