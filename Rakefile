#encoding: utf-8
require 'pg'
require 'yaml'

desc 'default'
task :default do
  puts "hello rake >_<"
end

namespace :db do

  desc 'build database and table'
  task :create do
    yml = YAML.load_file("config/database.yml")["product"]
    system("createdb -E UTF8 " + yml["dbname"])
    connection = PG::connect(yml)
    connection.exec(
"create table words(
id serial not null,
name text not null,
category int not null,
value int not null);"
         )
    connection.finish
  end
  
end
