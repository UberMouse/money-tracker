require 'rubygems'
require 'bundler'

Bundler.require

require_relative 'money_tracker'

use Rack::Reloader, 0
use Rack::ContentLength

run Sinatra::Application

