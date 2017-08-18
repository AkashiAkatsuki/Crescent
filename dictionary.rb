# coding: utf-8
require 'natto'
require 'yaml'
require 'active_record'


class Word < ActiveRecord::Base
  self.primary_key = 'id'
end

class Markov < ActiveRecord::Base
  self.primary_key = 'id'
  CHAIN_MAX = 10
  def self.learn(words)
    words.each_cons(3) do |w1, w2, w3|
      next if w1 == -1 || w2 == -1
      find_or_create_by(
        prefix1: w1.id,
        prefix2: w2.id,
        suffix:  w3.id)
    end
  end
  
  def self.generate(word_id)
    keyword = Word.find_by(id: word_id)
    seq = Array[word_id]
    first_list = where("prefix1 = ?", word_id)
    return keyword.name if first_list.empty?
    seq.push first_list.sample.prefix2
    CHAIN_MAX.times do
      choice = Markov.where("(prefix1 = ?) and (prefix2 = ?)", seq.last(2)[0], seq.last(2)[1]).sample.suffix
      break if choice == -1
      p Word.find(choice)
      redo if [true, false].sample && (Word.find(choice).value - keyword.value).abs > 1
      suffix = choice
      seq.push suffix
    end
    str = ""
    seq.each do |id|
      w = Word.find(id)
      str << w.name unless w.nil?
    end
    str
  end
end

class Friend < ActiveRecord::Base
  self.primary_key = 'screen_name'
  def self.add_friend(name, screen_name)
    if friend = find_by(screen_name: screen_name)
      friend.update(name: name)
    else
      create(name: name, screen_name: screen_name)
    end
  end
end

class Dictionary
  CATEGORY_HASH = {
    "名詞" => 0,
    "動詞" => 1,
    "形容詞" => 2,
    "副詞" => 3,
    "助詞" => 4,
    "接頭詞" => 5,
    "助動詞" => 6,
    "連体詞" => 7,
    "感動詞" => 8,
    "*" => 9
  }
  
  def initialize
    @mecab = Natto::MeCab.new
    yml = YAML.load_file("config/database.yml")
    yml[:adapter] = "postgresql"
    ActiveRecord::Base.establish_connection(yml)
  end
  
  def convert(input)
    mecabs = Array.new #For kill MeCabError
    words = Array.new
    @mecab.enum_parse(input).each do |n|
      mecabs.push Hash[:name, n.surface,
                       :category, CATEGORY_HASH[n.feature.split(",").first]]
    end
    mecabs.each do |m|
      if m[:category].nil?
        data = Word.new(id: -1, name: "EOS", category: -1, value: 0)
      else
        Word.find_or_create_by(name: m[:name], category: m[:category]){|d| d.value = 0}
        data = Word.find_by(name: m[:name], category:  m[:category])
      end
      words.push data
    end
    words
  end
  
  def learn_value(words)
    ave = 0
    words.select! {|w| Array[0, 1, 2, 8].include? w.category}
    words.each do |w|
      ave += w.value
    end
    ave /= words.size
    words.each do |w|
      if w.value > ave
        w.value -= (w.value - ave)/10.to_f
      else
        w.value += (ave - w.value)/10.to_f
      end
      w.save
    end
  end
  
  def set_value(input, value)
    mecab = Hash.new
    node = @mecab.enum_parse(input).first
    mecab = Hash[:name, node.surface,
                 :category, CATEGORY_HASH[node.feature.split(",").first]]
    return if mecab[:category].nil?
    unless Word.where("name = ?", mecab[:name]).update_all(value: value)
      Word.create(name: mecab[:name], category: mecab[:category], value: value)
    end
  end
  
  def learn_markov(words)
    Markov.learn(words)
  end
  
  def generate_markov(word_id)
    Markov.generate(word_id)
  end
  
  def add_friend(name, screen_name)
    Friend.add_friend(name, screen_name)
  end
  
end
