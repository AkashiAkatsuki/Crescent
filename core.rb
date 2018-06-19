# coding: utf-8
require 'yaml'
require './dictionary.rb'  

class Core
  attr_reader :name
  
  def initialize
    profile = YAML.load_file("config/profile.yml")
    @dic = Dictionary.new
    @name = profile['name']
    @learning_rate = profile['learning_rate']
    profile['values'].each do |word|
      @dic.set_value(word['name'], word['value'])
    end
    @moody_rate = profile['moody_rate']
    @mood = 0.5
    @max_trends = profile['max_trends']
    @max_speak_wait = profile['max_speak_wait']
    @ignore_trends = profile['ignore_trends']
    @none_reply = profile['none_reply']
  end

  def listen(input, member: "", screen_name: "")
    words = select_nouns(convert_words(input))
    if screen_name != ""
      add_trend(words.uniq)
      add_member(member, screen_name)
    end
  end

  def response(input, member: "", screen_name: "")
    add_member(member, screen_name) if screen_name != ""
    words = convert_words(input)
    value = @dic.average_of_value(words)
    affect_mood(value)
    keywords = select_nouns(words)
    return @dic.generate_markov(keywords.sample, value: value) unless keywords.empty?
    return @dic.generate_markov(@trends.last, value: value) unless @trends.nil?
    @none_reply
  end
  
  def speak
    @wait_count = 0 if @wait_count.nil?
    @wait_count += 1
    if @wait_count > @members.uniq.size
      @wait_count = 0
      keyword = @trends.max_by {|w| @trends.count(w)}
      @trends.delete_at(@trends.index(keyword))
      @dic.generate_markov(keyword, value: @mood)
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
    words
  end

  def select_nouns(words)
    words.select {|w| Array[0, 8].include? w.category}
  end
  
  def add_trend(words)
    words.delete_if {|w| @ignore_trends.include?(w.name)}
    if @trends.nil?
      @trends = words
    else
      @trends.concat words
    end
    @trends.delete_at(0) while @trends.size > @max_trends
  end
  
  def add_member(member, screen_name)
    @dic.add_friend(member, screen_name)
    @members = Array.new if @members.nil?
    @members.push member
    @members.delete_at(0) if @members.size > @max_speak_wait
  end

  def forget_old_words
    @dic.forget_old_words
  end

  def affect_mood(value)
    @mood += (value - @mood) * @moody_rate
  end
end
