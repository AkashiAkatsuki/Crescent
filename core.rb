# coding: utf-8
require 'yaml'
require './dictionary.rb'  

class Core
  attr_reader :name
  IGNORE_TREND = ["の", "ん", "ー"].freeze
  
  def initialize
    profile = YAML.load_file("config/profile.yml")
    @dic = Dictionary.new
    @name = profile['name']
    profile['values'].each do |word|
      @dic.set_value(word['name'], word['value'])
    end
  end
  
  def listen(input, member: "", screen_name: "")
    @dic.add_friend(member, screen_name)
    words = convert_words(input)
    add_trend(words.uniq)
    add_member(member)
    words.collect{|w| w.name}
  end

  def listen_from_search(input)
    convert_words(input)
  end
  
  def response(input, member: "", screen_name: "")
    @dic.add_friend(member, screen_name) if screen_name != ""
    words = convert_words(input)
    return @dic.generate_markov(words.sample.id) unless words.empty?
    return @dic.generate_markov(@trends.last.id) unless @trends.nil?
    'Zzz'
  end
  
  def speak
    @wait_count = 0 if @wait_count.nil?
    @wait_count += 1
    if @wait_count > @members.uniq.size
      @wait_count = 0
      keyword = @trends.max_by {|w| @trends.count(w)}
      @trends.delete_at(@trends.index(keyword))
      @dic.generate_markov(keyword.id)
    end
  end
  
  def convert_words(input)
    words = @dic.convert(input)
    @dic.learn_markov(words)
    @dic.learn_value(words)
    words.select {|w| Array[0, 8].include? w.category}
  end
  
  def add_trend(words)
      words.delete_if {|w| IGNORE_TREND.include?(w.name)}
      if @trends.nil?
        @trends = words
      else
        @trends.concat words
      end
      @trends.delete_at(0) while @trends.size > 100
  end
  
  def add_member(member)
    @members = Array.new if @members.nil?
    @members.push member
    @members.delete_at(0) if @members.size > 10
  end
  
end
