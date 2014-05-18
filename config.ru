require 'rubygems'
require 'bundler'
require 'pry'
require 'pry-byebug'

Bundler.require

require_relative 'money_tracker'

use Rack::ContentLength

run MoneyTracker.new

