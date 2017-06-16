# coding: utf-8
require 'yaml'
require './dictionary.rb'  

class Core
  include Dictionary
  attr_reader :name
  
  def initialize
    profile = YAML.load_file("config/profile.yml")
    @name = profile['name']
  end
  
  def listen(input, screen_name: "", name: "")
    words = convert(input)
    learn_markov(words)
    words
  end
  
  def response(input, screen_name: "", name:"")
    words = convert(input)
    learn_markov(words)
    nouns = words.select {|w| Array[0, 1, 2, 8].include? w.category}
    return "...?" if nouns.empty?
    generate_markov(nouns.sample.id)
  end

  def speak(input, screen_name: "", name: "")
    
  end

end
