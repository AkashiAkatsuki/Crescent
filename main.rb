# coding: utf-8
require 'bundler'
Bundler.require
require 'active_record'
require './core.rb'
require './twitter.rb'
require './webpage.rb'

core = Core.new
puts core.name + " got up."
name = "Default"
screen_name = ""

if /t/ === ARGV[0]
  Thread.new do
    TwitterManager.new(core).stream_start
  end
end

Thread.new do
  sleep 1
  while true
    print 'MENU (1)Talk (2)Speak (3)Name (4)Pry:'
    case STDIN.gets.to_i
    when 1 then
      while true
        print '> '
        input = STDIN.gets
        input.chomp!
        break if input == ''
        puts core.name + "> " + core.response(input, member: name, screen_name: screen_name)
      end
    when 2 then
      speak = core.speak
      puts core.name + "> " + speak if speak
    when 3 then
      print "Name: "
      name = gets.chomp
      print "ScreenName: "
      screen_name = STDIN.gets.chomp
    when 4 then
      binding.pry
    else
      exit
    end
  end
end

if /w/ === ARGV[0]
  Webpage.init core
  Webpage.run! host: 'localhost', port: 4567
end
