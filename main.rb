# coding: utf-8
require 'bundler'
Bundler.require
require 'active_record'
require './core.rb'

core = Core.new
puts core.name + " got up."

while true
  print '> '
  input = gets
  input.chomp!
  break if input ==''
  puts core.name + "> " + core.response(input)
end
