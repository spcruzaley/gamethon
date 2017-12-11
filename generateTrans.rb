#!/usr/bin/ruby

require 'digest'
require 'pry'

def sha256_double(message)
	return Digest::SHA256.hexdigest (Digest::SHA256.digest (message))
end

def sha256(message)
	return Digest::SHA256.hexdigest (message)
end

# "prev_hash": "0000000000000000000000000000000000000000000000000000000000000000",
# "vout": -1,
# "script_sig": "5468652076657279206669727374207472616e73616374696f6e206d6f746865726675636b657273"
# "value": 5000000000,
# "script": "ad15b1ddeac10e52020d82e667b96ec1709c3489"

puts "Should be"
puts "------------------------------------------------------------------------"
puts "591141d2b8795153cb75fef58ae6a4271563ad76a99d32127d0983f38f64b8c4"

prev_hash = ['0000000000000000000000000000000000000000000000000000000000000000'].pack('H*')
script_sig = ['5468652076657279206669727374207472616e73616374696f6e206d6f746865726675636b657273'].pack('H*')
vout = [-1].pack('i*')

value = [5000000000].pack('i*')
script_length = [40].pack('i*')
script = ['ad15b1ddeac10e52020d82e667b96ec1709c3489'].pack('H*')

version = [1].pack('i*')
inputs_length = [1].pack('i*')
#inputs_join = prev_hash.concat(script_sig.concat(vout
outputs_length = [1].pack('i*')
#outputs_join = value.concat(script_length.concat(script
lock_time = [0].pack('i*')

#Concatenando todo
# const = version.concat(inputs_length).concat(
#   prev_hash).concat(vout).concat(script_sig).concat(
#     outputs_length).concat(
#       value).concat(script_length).concat(script).concat(lock_time)
const = version.concat(inputs_length).concat(
  prev_hash).concat(vout).concat(script_sig).concat(
    outputs_length).concat(
      value).concat(script).concat(lock_time)
#binding.pry
puts sha256(const).reverse
puts sha256_double(const).reverse
puts
