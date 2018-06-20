#encoding: utf-8
require 'pg'
require 'yaml'
require 'active_record'
require './core.rb'

desc 'default'
task :default do
  puts "hello rake >_<"
end

namespace :db do

  desc 'build database and table'
  task :create do
    puts "Please 'rake db:config'"  unless yml = YAML.load_file("config/database.yml")
    system("createdb -E UTF8 " + yml["dbname"])
  end
  
  desc 'build table'
  task :table do
    yml = YAML.load_file("config/database.yml")
    yml[:adapter] = "postgresql"
    ActiveRecord::Base.establish_connection(yml)
    unless ActiveRecord::Base.connection.table_exists? :words
      ActiveRecord::Base.connection.create_table :words do |t|
        t.string :name
        t.int :category
        t.float :value, limit: 4
      end
    end
    unless ActiveRecord::Base.connection.table_exists? :markovs
      ActiveRecord::Base.connection.create_table :markovs do |t|
        t.int :prefix1
        t.int :prefix2
        t.int :suffix
      end
    end
    unless ActiveRecord::Base.connection.table_exists? :friends
      ActiveRecord::Base.connection.create_table :friends do |t|
        t.text :name
        t.text :screen_name
        t.float :love
      end
    end
  end
  
  desc 'database setting'
  task 'config' do
    hash = Hash.new
    hash["host"] = "localhost"
    print "user: "
    hash["user"] = STDIN.gets.chomp
    print "password: "
    hash["password"] = STDIN.gets.chomp
    print "dbname: "
    hash["dbname"] = STDIN.gets.chomp
    hash["port"] = "5432"
    YAML.dump(hash, File.open("config/database.yml", "w"))
  end
  
end

desc 'twitter authorization'
task :auth do
  hash = Hash.new
  print "consumer_key: "
  hash["consumer_key"] = STDIN.gets.chomp
  print "consumer_secret: "
  hash["consumer_secret"] = STDIN.gets.chomp
  print "access_token: "
  hash["access_token"] = STDIN.gets.chomp
  print "access_token_secret: "
  hash["access_token_secret"] = STDIN.gets.chomp
  YAML.dump(hash, File.open("config/twitter_auth.yml", "w"))
end

desc 'listening with textfile'
task :study do
  core = Core.new
  puts core.name + " got up."
  print "file name:"
  name = gets
  File.open(name, "r").read do |f|
    f.each_line do |line|
      core.listen(line)
    end
  end
end

