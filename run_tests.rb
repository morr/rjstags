#!/usr/bin/ruby
require 'test/unit'
$TEST = true
require 'rjstags'

Dir.foreach('test') do |filename|
  next if [".", ".."].include?(filename)
  require 'test/'+filename
end
