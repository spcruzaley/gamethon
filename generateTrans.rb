#!/usr/bin/ruby

require 'digest'
require 'pry'
#Custom classes
require './sha256'
require './constants'
require './utilities'

def bin_to_hex(s)
  s.unpack('H*').first
end

def getHexFromString(string)
	return ([string].map { |b| sprintf(", 0x%02x",b) }.join).dup.force_encoding('BINARY')
end

def value_to_binary_string(val)
  val = val.to_i

  if val < -0xffffffffffffffff # unrepresentable
      ""
  elsif val < 0    # 64-bit negative integer
      top_32 = ((-val) & 0xffffffff00000000) >> 32
      btm_32 = (-val) & 0x00000000ffffffff
      [0xff, top_32, btm_32].pack("CVV")
  elsif val <= 0xfc # 8-bit (almost) positive integer
      [val].pack("C")
  elsif val <= 0xffff # 16-bit positive integer
      [0xfd, val].pack("Cv")
  elsif val <= 0xffffffff # 32-bit positive integer
      [0xfe, val].pack("CV")
  else    # We can't represent this, whatever it is
      ""
  end
end

prev_hash = "0000000000000000000000000000000000000000000000000000000000000000"
vout = -1
script_sig = "5468652076657279206669727374207472616e73616374696f6e206d6f746865726675636b657273"
value = 5000000000
script = "ad15b1ddeac10e52020d82e667b96ec1709c3489"

puts "------------------------------------------------------------------------"
puts "Hash to be:  591141d2b8795153cb75fef58ae6a4271563ad76a99d32127d0983f38f64b8c4"

coinbase = {
	inputs: [
		{
			prev_hash: [prev_hash.to_s].pack('H*'),
			script_sig: [script_sig].pack('H*'),
			#vout: " 2d 31".force_encoding('BINARY')
			#vout: [getHexFromString(Constants::MINUS_ONE)].pack('H*')
			vout: [Utilities::int_to_binary(Constants::MINUS_ONE)].pack('H*')
		}
	],
	outputs: [
		{
			script: [script].pack('H*'),
			#value: [getHexFromString(value.to_s)].pack('H*'),
			value: [Utilities::int_to_binary(value)].pack('H*'),
			#value: " 35 30 30 30 30 30 30 30 30 30".force_encoding('BINARY'),
		}
	]
}

transaction = {
	version: [Utilities::int_to_binary(Constants::VERSION)].pack('H*'),
	#version: [getHexFromString(Constants::VERSION.to_s)].pack('H*'),
	#version: " 31".force_encoding('BINARY'),

	inputs_length: [Utilities::int_to_binary(coinbase[:inputs].length.to_i)].pack('H*'),
	#inputs_length: [getHexFromString(coinbase[:inputs].length.to_s)].pack('H*'),
	#inputs_length: " 31".force_encoding('BINARY'),
	inputs_map_join: coinbase[:inputs].map{|k| k.values}.join,

	#outputs_length: [getHexFromString(coinbase[:outputs].length.to_s)].pack('H*'),
	outputs_length: [Utilities::int_to_binary(coinbase[:outputs].length.to_i)].pack('H*'),
	#outputs_length: " 31".force_encoding('BINARY'),
	outputs_map_join: coinbase[:outputs].map{|k| k.values}.join.split.join,

	lock_time: [Utilities::int_to_binary(Constants::LOCK_TIME)].pack('H*')
	#lock_time: [getHexFromString(Constants::LOCK_TIME.to_s)].pack('H*')
	#lock_time: " 30".force_encoding('BINARY')
}
binding.pry
transac = Sha256::sha256_double(bin_to_hex(transaction.values.join))
puts "Hash gotten: #{transac.reverse}"
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
