require 'curb-fu'
require 'uri'
require 'json'
require 'hashie'
require 'pry'
require 'pry-byebug'

class BNZImporter
  ROOT_URL = 'www.bnz.co.nz'

  def initialize(access_number, password)
    @j_session_id = login(access_number, password)
  end

  def import
    trans = transactions
    binding.pry
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

  def transactions
    api_endpoint = '/ib/api/transactions'

    response = CurbFu.get(:host => ROOT_URL,
                          :path => api_endpoint,
                          :protocol => 'https',
                          :headers => {'Cookie' => @j_session_id})

    json = JSON.parse(response.body)
    json.slice(0, 50).map{|trans| Hashie::Mash.new trans}
  end
end