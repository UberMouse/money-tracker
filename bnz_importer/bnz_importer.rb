require 'sequel'
require 'curb-fu'
require 'uri'
require 'json'
require 'hashie'
require 'digest'

class BNZImporter
  ROOT_URL = 'www.bnz.co.nz'

  def initialize(access_number, password)
    @j_session_id = login(access_number, password)
    db = Sequel.sqlite('transactions.db')

    unless db.table_exists?(:transactions)
     db.create_table :transactions do
       primary_key :id, :integer, :auto_increment => true
       Long :date
       Int :amount
       String :formatted_amount
       String :description
       String :transaction_hash
     end
    end

    @transactions = db[:transactions]
  end

  def import
    transactions = convert_bnz_transactions_to_generic_transactions get_transactions

    for transaction in transactions do
      @transactions.insert(:date => transaction.date,
                           :amount => transaction.amount,
                           :description => transaction.description,
                           :formatted_amount => transaction.formatted_amount,
                           :transaction_hash => transaction.transaction_hash)
    end
  end

  def convert_bnz_transactions_to_generic_transactions(bnz_transactions)
    bnz_transactions.map do |transaction|
      Hashie::Mash.new({
       :date => Time.parse(transaction.date).to_i,
       :amount => transaction.amount,
       :formatted_amount => transaction.formattedAmount,
       :description => transaction.description,
       :transaction_hash => Digest::MD5.hexdigest(transaction.description + transaction.amount.to_s  + transaction.date)})
    end
  end

  def login(access_number, password)
    api_endpoint = '/ib/app/login'
    ua = 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.137 Safari/537.36'
    response = CurbFu.post({:host => ROOT_URL,
                            :path => api_endpoint,
                            :protocol => 'https',
                            :headers => {'User-Agent'=> ua}},
                           {:accessId => access_number,
                            :password => password})

    response.headers['Set-Cookie'].split(';')[0]
  end

  def get_transactions
    api_endpoint = '/ib/api/transactions'

    response = CurbFu.get(:host => ROOT_URL,
                          :path => api_endpoint,
                          :protocol => 'https',
                          :headers => {'Cookie' => @j_session_id})

    json = JSON.parse(response.body)
    json.slice(0, 50).map{|trans| Hashie::Mash.new trans}
  end
end