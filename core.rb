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
    @learning_rate = profile['learning_rate']
    profile['values'].each do |word|
      @dic.set_value(word['name'], word['value'])
    end
  end

  def listen(input, member: "", screen_name: "")
    words = convert_words(input)[:words]
    if screen_name != ""
      @dic.add_friend(member, screen_name)
      add_trend(words.uniq)
      add_member(member)
      words.collect{|w| w.name}
    end
  end

  def response(input, member: "", screen_name: "")
    @dic.add_friend(member, screen_name) if screen_name != ""
    conv = convert_words(input)
    return @dic.generate_markov(conv[:words].sample, value: conv[:value]) unless conv[:words].empty?
    return @dic.generate_markov(@trends.last.id, value: conv[:value]) unless @trends.nil?
    'Zzz'
  end
  
  def speak
    @wait_count = 0 if @wait_count.nil?
    @wait_count += 1
    if @wait_count > @members.uniq.size
      @wait_count = 0
      keyword = @trends.max_by {|w| @trends.count(w)}
      @trends.delete_at(@trends.index(keyword))
      @dic.generate_markov(keyword)
    end
  end
  
  def new_words
    @dic.new_words
  end
  
  def clear_new_words
    @dic.new_words = Array.new
  end
  
  def convert_words(input)
    words = @dic.convert(input)
    @dic.learn_markov(words)
    @dic.learn_value(words, @learning_rate)
    value = @dic.average_of_value(words)
    words.select! {|w| Array[0, 8].include? w.category}
    {words: words, value: value}
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

  def forget_old_words
    @dic.forget_old_words
  end
end
