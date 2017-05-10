# coding: utf-8
require 'bundler'
Bundler.require
require 'active_record'
require './core.rb'

kure = Core.new("Kuretsuki")
puts kure.name + " got up."

while true
  print '> '
  input = gets
  input.chomp!
  break if input ==''
  puts kure.name + "> " + kure.response(input)
end
