#!/usr/bin/env ruby
require 'rubygems'
require 'premailer'

raise "Need an input file" unless ARGV.length > 0
input = ARGV[0]

premailer = Premailer.new(input,:warn_level => Premailer::Warnings::SAFE)
puts premailer.to_inline_css
