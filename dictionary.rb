# coding: utf-8
require 'natto'
require 'yaml'
require 'active_record'
require 'weighted_randomizer'

yml = YAML.load_file("config/database.yml")
yml[:adapter] = "postgresql"
ActiveRecord::Base.establish_connection(yml)

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

  def self.generate(keyword, value: 0.5)
    seq = Array[keyword]
    first_markovs = where("prefix1 = ?", keyword.id)
    first_ids = first_markovs.map { |m| m.prefix2 }
    first_word = choice_word(first_ids, value)
    return keyword.name if first_word.nil?
    seq.push first_word
    CHAIN_MAX.times do
      suggest_markovs = Markov.where("(prefix1 = ?) and (prefix2 = ?)",
                                     seq.last(2)[0].id,
                                     seq.last(2)[1].id)
      suggest_ids = suggest_markovs.map{ |m| m.suffix }
      choice = choice_word(suggest_ids, value)
      break if choice.nil?
      seq.push choice
    end
    str = ""
    seq.each do |w|
      unless w.nil?
        str << w.name
        str << ' ' if (w.name =~ /^[A-Za-z]+$/) == 0
      end
    end
    str
  end

  private
  def self.choice_word(word_ids, value)
    return if word_ids.empty?
    table = Hash.new
    word_ids.each do |wi|
      if wi == -1
        table[nil] = 0.1
        next
      end
      w = Word.find(wi)
      table[w] = 1 - (value - w.value).abs
    end
    WeightedRandomizer.new(table).sample
  end
end

class Friend < ActiveRecord::Base
  self.primary_key = 'id'
end

class Dictionary
  attr_accessor :new_words

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
    @new_words = Array.new
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
        data = Word.new(id: -1, name: "EOS", category: -1, value: 0.5)
      else
        word = Word.find_or_create_by(name: m[:name], category: m[:category]) do |d|
          d.value = 0.5
          @new_words.push d.name
        end
        data = Word.find_by(name: m[:name], category:  m[:category])
      end
      words.push data
    end
    words
  end

  def learn_value(words, learning_rate)
    ave = average_of_value(words)
    selected_words = select_words(words)
    selected_words.each do |w|
      next if w.value == 1 || w.value == 0
      w.value += (ave - w.value) * learning_rate
      w.save
    end
  end

  def select_words(words)
    words.select {|w| Array[0, 1, 2, 8].include? w.category}
  end

  def average_of_value(words)
    selected_words = select_words(words)
    values = selected_words.map{ |v| v.value }
    return 0.5 if values.empty?
    values.inject(:+)/selected_words.size.to_f
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

  def generate_markov(keyword, value: 0.5)
    Markov.generate(keyword, value: value)
  end

  def update_friend(name, screen_name, value, rate)
    if friend = Friend.find_by(screen_name: screen_name)
      love = friend.love + (value - friend.love) * rate
      friend.update(name: name, love: love)
    else
      love = 0.5 + (value - 0.5) * rate
      friend = Friend.create(name: name, screen_name: screen_name, love: love)
    end
  end

  def forget_old_words
    old_words = Word.where('updated_at < ? AND created_at > ?', 1.months.ago, 3.months.ago)
    old_words.each do |w|
      Markov.where('(prefix1 = ?) OR (prefix2 = ?) OR (suffix = ?)', w.id, w.id, w.id).delete_all
      w.delete
    end
  end

end
