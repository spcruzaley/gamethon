require 'rubygems'
require 'digest'
require 'json'
require 'rest-client'
require 'pry'

class ApiRest

  $url

  def initialize(testnet)
    # Instance variables
    $url = "https://gameathon.mifiel.com/api/v1/games/#{testnet}/"
  end

  def query_get(resource)
    puts "*********************************************************************"
   	puts "[Getting data from ==> #{$url}#{resource}]"
   	puts ""

    response = RestClient::Request.execute(
      :method => :get,
  		:url => $url.to_s + resource.to_s,
  		:ssl_version => 'SSLv23'
  	)
  	return JSON.parse(response, symbolize_names: true)
  end

  def query_post(payload, resource)
    puts "*********************************************************************"
   	puts "[Sending POST data to ==> #{$url}#{resource}]"
   	puts ""

    response = RestClient::Request.execute(
      :method => :post,
 		  :url => $url.to_s + resource.to_s,
 		  :payload => payload.to_json,
 		  :ssl_version => 'SSLv23',
 		  :headers => {
        :content_type => :json,
 			  :accept => :json
 		  }
 	  )

    return JSON.parse(response, symbolize_names: true)
    rescue RestClient::Exception => e
     puts ""
   	 puts "ERROR Inspect: #{e.inspect}"
   	 puts "ERROR Response: #{e.response}"
   	 puts "************************************************"
  end

  #-----------------------------------
  #Functional methods for API
  #-----------------------------------
  def get_blocks
  	puts "Getting last blocks..."
  	response = query_get('blocks')

    return response
  end

  def get_last_target
  	puts "Getting last target..."
    response = query_get('target')

    return response[:target]
  end

  def get_pool
  	puts "Getting pool..."
    response = query_get('pool')

    return response
  end

end
