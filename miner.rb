#!/usr/bin/ruby

require 'digest'
require 'net/http'
require 'json'

#-----------------------------------
#CONSTANTS
#-----------------------------------
BLANK = ""
ZERO = 0
VERSION = "1"
PIPE = "|"
NICKNAME = "spcruzaley"

#-----------------------------------
#Functional methods
#-----------------------------------

#Generates a sha256 hash
def sha256_simple(message)
	return Digest::SHA256.hexdigest (message)
end

#Generates a double sha256 hash
def sha256_double(message)
	return Digest::SHA256.hexdigest (Digest::SHA256.digest (message))
end

#Hash generation, this method will return the poosible hash to win the reward
def generate_hash(prev_block_hash, merkle_hash, message, nonce)
	return sha256_double(concat_str(PIPE,VERSION,prev_block_hash,merkle_hash,get_last_target,message,nonce))
end

#Generate the merkle root
def merkle_root(*hashes)
  if hashes.length > 1
    return sha256_simple(concat_str(BLANK,*hashes))
  else
    return hashes[0]
  end
end

#-----------------------------------
#Utilities
#-----------------------------------

#Concat several string with the indicated separator
def concat_str(separator, *strings)
	concatenated_str = ""
  sep_length = separator.length

  strings.each do |word|
    concatenated_str << word << separator
  end

  if sep_length > ZERO
    return concatenated_str[0..((sep_length*-1)-1)]
  else
    return concatenated_str
  end
end

def get_last_target
  url = 'https://gameathon.mifiel.com/api/v1/games/testnet/target'
  uri = URI(url)
  response = Net::HTTP.get(uri)
  obj = JSON.parse(response)

  return obj['target']
end

def get_merkle_from_pool
  url = 'https://gameathon.mifiel.com/api/v1/games/testnet/pool'
  uri = URI(url)
  response = Net::HTTP.get(uri)
  obj = get_array_from_json(JSON.parse(response))
  # obj = get_array_from_json_dummy()

  i = 0
  current_pos = 0
  hashA = ''
  hashB = ''
  txlength = obj.length

  while (txlength-1) > current_pos
    if i < (txlength -1)
      hashA = obj[i].to_s
      i += 1
      hashB = obj[i].to_s
      i += 1

      obj[current_pos] = sha256_double(hashA << hashB)
      current_pos += 1
    else
			hashA = obj[i].to_s
      hashB = obj[i].to_s
      obj[current_pos] = sha256_double(hashA << hashB)
      txlength = current_pos
      current_pos = 0
      i = 0
    end

  end

  return sha256_double(obj[0] << obj[1])
end

def get_last_block
	url = 'https://gameathon.mifiel.com/api/v1/games/testnet/blocks'
  uri = URI(url)
  response = Net::HTTP.get(uri)
  obj = JSON.parse(response)

	return obj[obj.length-1]
end

def get_array_from_json(json_object)
  arr = json_object
  i = 0

  while i < json_object.length do
    arr[i] = json_object[i]['hash']
    i += 1
  end

  return arr
end

def send_data(prev_block_hash, nonce, merkle_hash, generated_hash)
	uri = URI.parse("https://gameathon.mifiel.com/api/v1/games/testnet/block_found")

	header = {'Content-Type': 'text/json'}
	data_to_send = "{
		\"prev_block_hash\":\"#{prev_block_hash}\",
		\"height\":\"2\",
		\"message\":\"#{NICKNAME}\",
		\"nonce\":\"#{nonce}\",
		\"nickname\":\"#{NICKNAME}\",
		\"merkle_root\":\"#{merkle_hash}\",
		\"transactions\": {
				\"hash\":\"#{generated_hash}\",
				\"inputs\":{
						\"prev_hash\":\"#{prev_block_hash}\",
						\"vout\":\"-1\",
						\"script_sig\":\"123456789012345678901\"
					}
				},
				\"outputs\":{
						\"vaue\":\"5000000000\",
						\"script\":\"03627eac6729a1f3f210dbfba4f9e21d6bfdce764e00b7559cc68a7551ddd839bf\"
				}
			}
		}"

		puts data_to_send

	# Create the HTTP objects
	http = Net::HTTP.new(uri.host, uri.port)
	request = Net::HTTP::Post.new(uri.request_uri, header)
	request.body = data_to_send.to_json

	# Send the request
	response = http.request(request)

	return response
end

#---------------------------------------------------------------
# Manual test cases
#---------------------------------------------------------------

#Validate the correct process to generate the hash
def test_hash_generation
  puts "---------------------------------------------------------------"
  puts "Testing hash generation..."
  puts ""
  hash_to_be = "00000a32767f5fc0a06e64b4688d0da8895d3e79d44e33076b667e5cd35ac912"
  hash_gotted = generate_hash(
    "0000000000000000000000000000000000000000000000000000000000000000",
    "e2ff1b9ea442fd4dff79822fd9fb577a6cb5d17e4571fd1baeaf3710fb36b2e6",
    "Yo mero",
    "5028817")
  if hash_to_be == hash_gotted
    puts "SUCCESS !!"
    puts "Hash to be: #{hash_to_be}"
    puts "Hash gotten: #{hash_gotted}"
  else
    puts "FAILURE !!"
  end
end

#Validate the correcto process to generate the merkle hash
def test_merkle_generation
  puts "---------------------------------------------------------------"
  puts "Testing merkle root generation..."
  puts ""
  hash_to_be = "f0ae517fa354e6845eb0d2ac98f3eacd4cafce04a240bede8f405642f9106c49"
  hash_gotted = merkle_root(
    "0000000000000000000000000000000000000000000000000000000000000000",
    "e2ff1b9ea442fd4dff79822fd9fb577a6cb5d17e4571fd1baeaf3710fb36b2e6")
  if hash_to_be == hash_gotted
    puts "SUCCESS !!"
    puts "Hash to be: #{hash_to_be}"
    puts "Hash gotten: #{hash_gotted}"
  else
    puts "FAILURE !!"
  end
end

#---------------------------------------------------------------
#Executing test cases
#---------------------------------------------------------------
# test_hash_generation
# test_merkle_generation

#Calls to API
# puts get_last_target
# puts get_merkle_from_pool
# puts get_last_block

def initial_method
	#Get the last data from the node
	last_data = get_last_block

	prev_block_hash = last_data['prev_block_hash']
	merkle_hash = get_merkle_from_pool
	message = "Yo merengues"
	nonce = 0

	while true do
		#Generate the hash with the current info
		hash_generated = generate_hash(prev_block_hash, merkle_hash, message, nonce.to_s)

		hash_int = (hash_generated.hex.to_s(2).rjust(hash_generated.size*4, '0')).to_i(2)
		target_int =  (get_last_target.hex.to_s(2).rjust(get_last_target.size*4, '0')).to_i(2)

		puts "Nonce: #{nonce.to_s} - Hash: #{hash_generated}"
		if(hash_int < target_int)
			puts "Found !"
			break;
		end
		nonce += 1
	end


	#Send the info
	#resp = send_data(prev_block_hash, nonce, merkle_hash, hash_generated)
	#puts resp
end

initial_method
