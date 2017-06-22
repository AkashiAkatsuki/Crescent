# coding: utf-8
require 'yaml'
require './dictionary.rb'  

class Core
  include Dictionary
  attr_reader :name
  
  def initialize
    profile = YAML.load_file("config/profile.yml")
    @name = profile['name']
    @trends = Array.new
  end
  
  def listen(input, screen_name: "", name: "")
    words = convert(input)
    learn_markov(words)
    @trends.push(words.select {|w| Array[0, 1, 2, 8].include? w.category}.sample)
    p @trends
    words
  end

  def speak(screen_name: "", name: "")
    generate_markov(@trends.last.id)
  end

end
