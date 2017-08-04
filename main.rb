# coding: utf-8
require 'bundler'
Bundler.require
require 'active_record'
require './core.rb'

core = Core.new
puts core.name + " got up."
name = "Default"
screen_name = ""

while true
  print 'MENU (1)Talk (2)Speak (3)Name:'
  case gets.to_i
  when 1 then
    while true
      print '> '
      input = gets
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
    screen_name = gets.chomp
  else
    break
  end  
end
