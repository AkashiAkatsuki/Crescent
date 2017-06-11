# coding: utf-8
require 'natto'
require 'active_record'
require 'yaml'
require './word.rb'
require './markov.rb'

yml = YAML.load_file("config/database.yml")
yml[:adapter] = "postgresql"
ActiveRecord::Base.establish_connection(yml)

module Dictionary
  CHAIN_MAX = 10
  CATEGORY_HASH = { "名詞" => 0,
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
    
  
  def convert(input)
    mecabs = Array.new #For kill MeCabError
    words = Array.new
    Natto::MeCab.new.enum_parse(input).each do |n|
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
    words.select! {|w| {0, 1, 2}.include? w.category}
    words.each do |w|
      ave += find_by(id: w.id).value
    end
    ave /= words.size
    words.each do |w|
      # w.value *= ave
    end
  end
  
  def learn_markov(words)
    words.each_cons(3) do |w1, w2, w3|
      next if w1 == -1 || w2 == -1
      Markov.find_or_create_by(
        prefix1: w1.id,
        prefix2: w2.id,
        suffix:  w3.id)
    end
  end
  
  def generate_markov(word_id)
    seq = Array[word_id]
    seq.push  Markov.where("prefix1 = ?", word_id).sample.prefix2
    CHAIN_MAX.times do
      suffix = Markov.where("(prefix1 = ?) and (prefix2 = ?)", seq.last(2)[0], seq.last(2)[1]).sample.suffix
      break if suffix == -1
      seq.push suffix
    end
    str = ""
    seq.each do |id|
      str << Word.find_by(id: id).name
    end
    str
  end
  
end
