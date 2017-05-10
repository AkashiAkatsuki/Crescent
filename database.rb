# coding: utf-8
require 'bundler'
require 'active_record'
require 'yaml'
Bundler.require

yml = YAML.load_file("config/database.yml")["product"]
yml[:adapter] = "postgresql"
ActiveRecord::Base.establish_connection(yml)

class Word < ActiveRecord::Base
  enum category: { noun: 0,
                   verb: 1,
                   adjective: 2,
                   adverb: 3,
                   particle: 4,
                   conjunction: 5,
                   auxiliary: 6,
                   prenoun: 7,
                   interjection: 8,
                   etc: 9
                 }
  
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

  def category=(value)
    if(CATEGORY_HASH.key?(value))
      write_attribute(:category, CATEGORY_HASH[value])
    else
      write_attribute(:category, value)
    end
  end

end
