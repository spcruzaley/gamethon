#!/usr/bin/ruby

require 'digest'
require 'net/http'
require 'json'
require 'base64'

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
def generate_hash(prev_block_hash, merkle_hash, last_target, message, nonce)
	return sha256_double(concat_str(PIPE,VERSION,prev_block_hash,merkle_hash,last_target,message,nonce))
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

def write_file(name, data)
	File.open(name, 'w') {
    |file| file.write(data)
  }
end

def read_file(name)
  counter = 0
  File.open(name, "r") do |infile|
      while (line = infile.gets)
          puts line
          counter = counter + 1
      end
  end
end

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


#Get the last data from the node
last_data = get_last_block
puts "last_data #{last_data}"

#Get the last target
ltarget = get_last_target
puts "ltarget #{ltarget}"

prev_block_hash = last_data['prev_block_hash']
puts "prev_block_hash #{prev_block_hash}"
merkle_hash = get_merkle_from_pool
puts "merkle_hash #{merkle_hash}"
message = "Yo merengues"
nonce = 0
prng = Random.new
prng.rand(10000000)

while true do
	nonce = prng.rand(10000000).to_i
	#Generate the hash with the current info
	hashe = generate_hash(prev_block_hash, merkle_hash, ltarget, message, nonce.to_s)

	hash_int = hashe.to_i(16)
	target_int = hashe.to_i(16)

	# puts "[hashInt #{hash_int}: targetInt #{target_int}]"
	puts "Nonce: #{nonce.to_s} - Hash: #{hash_generated}"
	if(hash_int < target_int)
		puts "Found !"
		break;
	end
	nonce += 1
end
