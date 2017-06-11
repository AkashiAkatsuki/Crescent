# coding: utf-8
require 'natto'
require 'yaml'
require './dictionary.rb'  

class Core
  include Dictionary
  attr_reader :name
  
  RESPONSE_CATEGORY = /名詞|感動詞/
  
  def initialize()
    profile = YAML.load_file("config/profile.yml")
    @name = profile['name']
  end
  
  def listen(input, screen_name: "", name: "")
    learn_markov(convert(input))
  end
  
  def response(input, screen_name: "", name:"")
    words = convert(input)
    learn_markov(words)
    nouns = words.select {|w| w.category == 0}
    return "...?" if nouns.empty?
    generate_markov(nouns.sample.id)
  end

  def speak(input, screen_name: "", name: "")
    
  end

end
