#!/usr/bin/ruby

require 'digest'
require 'pry'
#Custom classes
require './sha256'
require './constants'
require './utilities'

# prev_hash = "0000000000000000000000000000000000000000000000000000000000000000"
# vout = -1
# script_sig = "47656e61726f3334333139"
# value = 5035000448
# script = "1f4e24ae96324bb8c765fffb34708247036cff86"
# hash_to_be = eb103aecd49c3c943614eecfa0ad53db265b38dac33892ef4a502e7d944eb43e

prev_hash = "0000000000000000000000000000000000000000000000000000000000000000"
vout = -1
script_sig = "d9e53e0754b6ba2d600b56ab647bc030"
value = 156250000
script = "9816312418cd1fce9f1638943f66785b7af171f0"
hash_to_be = ""

puts "------------------------------------------------------------------------"
puts "Hash to be:  #{hash_to_be}"

coinbase = [
	inputs: [
			[prev_hash].pack('H*'),
			[script_sig].pack('H*'),
      vout
	],
	outputs: [
      value,
      [script].pack('H*').length,
		  [script].pack('H*')
	]
]

transaction = [
  Constants::VERSION,
  Constants::ONE, #Inputs length
  coinbase[0][:inputs].join,
  Constants::ONE, #Outputs length
  coinbase[0][:outputs].join,
  Constants::LOCK_TIME
].join

transac = Sha256::sha256_double(transaction).reverse
puts "Hash gotten: #{transac}"
puts "---------------------------------------------------------------------"


# coinbase = {
# 	inputs: [
# 		{
# 			prev_hash: value_to_binary_string(prev_hash),
# 			script_sig: value_to_binary_string(script_sig),
# 			vout: value_to_binary_string(Constants::MINUS_ONE_INT.to_s)
# 		}
# 	],
# 	outputs: [
# 		{
# 			value: value_to_binary_string(value),
# 			script_length: value_to_binary_string(script.length.to_s),
# 			script: value_to_binary_string(script)
# 		}
# 	]
# }
#
# transaction = {
# 	version: value_to_binary_string(Constants::VERSION.to_s),
# 	inputs_length: value_to_binary_string(coinbase[:inputs].length.to_s),
# 	inputs_map_join: coinbase[:inputs].map{|k| k.values}.join,
# 	outputs_length: value_to_binary_string(coinbase[:outputs].length.to_s),
# 	outputs_map_join: coinbase[:outputs].map{|k| k.values}.join.split.join,
# 	lock_time: value_to_binary_string(Constants::LOCK_TIME.to_s)
# }
#
# transac = Sha256::sha256_double(bin_to_hex(transaction.values.join))
# binding.pry
# puts "Hash gotten: #{transac.reverse}"
# puts "---------------------------------------------------------------------"
