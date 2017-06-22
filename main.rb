# coding: utf-8
require 'bundler'
Bundler.require
require 'active_record'
require './core.rb'

core = Core.new
puts core.name + " got up."

while true
  print 'MENU (1)Talk:'
  case gets.to_i
  when 1 then
    while true
      print '> '
      input = gets
      input.chomp!
      break if input == ''
      words = core.listen(input)
      puts core.name + "> " + core.speak
    end
  else
    break
  end
  
end
