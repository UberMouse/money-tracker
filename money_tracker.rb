require 'sinatra'
require_relative 'bnz_importer/bnz_importer'

class MoneyTracker < Sinatra::Application
  get '/' do
    BNZImporter.new('', '').import
  end
end