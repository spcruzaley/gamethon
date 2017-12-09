#!/usr/bin/ruby

require 'digest'

#-----------------------------------
#CONSTANTS
#-----------------------------------
BLANK = ""
ZERO = 0
VERSION = "1"
PIPE = "|"
TARGET = "00000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"

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
	return sha256_double(concat_str(PIPE,VERSION,prev_block_hash,merkle_hash,TARGET,message,nonce))
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
test_hash_generation
test_merkle_generation
