#encoding: utf-8
require 'pg'
require 'yaml'
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
    puts "Please 'rake db:config'"  unless yml = YAML.load_file("config/database.yml")
    connection = PG::connect(yml)
    if connection.exec("select relname from pg_class where relname = 'words';").ntuples == 0
      connection.exec("
create table words(
id serial not null,
name text not null,
category int not null,
value decimal not null);")
    end
    if connection.exec("select relname from pg_class where relname = 'markovs';").ntuples == 0
      connection.exec("
create table markovs(
id serial not null,
prefix1 int not null,
prefix2 int not null,
suffix int not null);")  
    end
    if connection.exec("select relname from pg_class where relname = 'friends';").ntuples == 0
      connection.exec("
create table friends(
id serial not null,
name text not null,
screen_name text not null);")
    end
    connection.finish
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

