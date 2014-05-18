require 'sinatra'
require 'sequel'
require 'haml'
require 'hashie'
require_relative 'bnz_importer/bnz_importer'

class MoneyTracker < Sinatra::Application
  get '/' do
    db = Sequel.sqlite('transactions.db')

    transactions = db[:transactions].all.map{|t| Hashie::Mash.new t}

    haml :index, :locals => {:transactions => transactions}
  end

  get '/sync' do
    BNZImporter.new('', '').import
  end
end