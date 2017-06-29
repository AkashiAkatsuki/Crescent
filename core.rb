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
  
  def listen(input, member: "")
    words = convert(input)
    learn_markov(words)
    words.select! {|w| Array[0, 8].include? w.category}
    if member != ""
      add_trend(words.uniq)
      add_member(member)
    end
    words.collect{|w| w.name}
  end
  
  def response(input, member: "")
    listen(input, member: member)
    p @trends
    generate_markov(@trends.last.id)
  end
  
  def speak
    @wait_count = 0 if @wait_count.nil?
    @wait_count += 1
    if @wait_count > @members.uniq.size
      @wait_count = 0
      generate_markov(@trends.max_by {|w| @trends.count(w)}.id)
    end
  end
  
  def add_trend(words)
    if @trends.nil?
      @trends = words
    else
      @trends.concat words
    end
    @trends.delete_at(0) if @trends.size > 100
  end
  
  def add_member(member)
    @members = Array.new if @members.nil?
    @members.push member
    @members.delete_at(0) if @members.size > 10
  end
  
end
