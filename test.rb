#!/usr/bin/ruby
require 'rubygems'
require 'digest'
require 'json'
require 'base64'
require 'rest-client'
require 'pry'
require 'securerandom'
require 'time'
#Custom classes
require './apirest'
require './sha256'
require './constants'
require './utilities'

def generate_merkle_root(data)
  puts "Generating merkle root hash..."
  obj = data.map{|v|v[:hash]}

  i = 0
  current_pos = 0
  hashA = ''
  hashB = ''
  txlength = obj.length

  if obj.length <= 1
    return Sha256::sha256_double(obj[0])# << obj[0])
  else
    while (txlength-1) > current_pos
      if i < (txlength -1)
        hashA = obj[i].to_s
        i += 1
        hashB = obj[i].to_s
        i += 1

        obj[current_pos] = Sha256::sha256_double(hashA << hashB)
        current_pos += 1
      else
        hashA = obj[i].to_s
        hashB = obj[i].to_s
        obj[current_pos] = Sha256::sha256_double(hashA << hashB)
        txlength = current_pos
        current_pos = 0
        i = 0
      end
    end
    return Sha256::sha256_double(obj[0] << obj[1])
  end
end

data = {
  hash [
    "4c714086e821264e94a5412f8043e5c6041b67ec99bd7dca66dac67bc11ceaa8",
    "f0bc70e6e0d168efbe10f2179ab22f9810fbe8dfad7ea69d3c638c9b9194a631",
    "b3c212a29c16081301b7e95edef583bb8ec8c3302f66673b411638f993a00cb1"
  ]
}
#3be8ebc0015efd24cd321412ca90883ddf602d87cb2b4a9d842447f02967d1d0
