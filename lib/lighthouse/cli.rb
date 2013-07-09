require "rubygems"
require "bundler/setup"
require 'optparse'
require 'lighthouse-api'
require 'pp'

Dir[File.expand_path("../cli/*rb", __FILE__)].each {|file| require file }

