require "rubygems"
require "bundler/setup"
require 'optparse'
require 'yaml'
require 'pp'
require 'json'


Dir[File.expand_path("../cli/*rb", __FILE__)].each {|file| require file }
