#!/usr/bin/ruby

require 'time'
require './miner'

testnet = ARGV[0]

if testnet.nil?
  testnet = "testnet3"
end

#Object to miner
$miner = Miner.new(testnet)
$block
mining = false

while true do

  if !mining
    #Get all the current blocks
    current_blocks = $miner.get_info_blocks

    #Get last block info
    last_block_info = $miner.get_last_block(current_blocks)
  else
    current_blocks = $block
    last_block_info = $block
  end

  #Get the current target
  target = $miner.get_current_target

  #Getting pool data
  #data_pool = $miner.get_pool_info

  #Generate the merkle root from pool
  #merkle_root = $miner.generate_merkle_root(data_pool)

  #Get the reward (tomar el height de la info del ultimo bloque)
  reward = $miner.get_reward(last_block_info)
  #fee = $miner.get_fees(current_blocks)
  #reward_and_fee = reward + fee

  #Generate hash transaction
  script_sig = SecureRandom.hex()
  hash_trnx = $miner.generate_hash_transaction(reward, script_sig)

  #NOTE: I putted the merkle root as the hash transaction because the transaction only has one
  # TODO: But I need to fix this method
  merkle_root = hash_trnx

  puts "Start to mining..."
  start = Time.now
  nonce = 1
  while true do
    if(nonce % 100000 == 0)
      puts "Current nonce [#{nonce}]"
    end

    #Generar mew hash
    hash_generated = $miner.generate_hash(last_block_info, target, merkle_root, nonce)

    #Validate the hash
    if(hash_generated.to_i(16) < target.to_i(16))
      puts
      puts "---------------------------------------------------------------------"
      puts "Block found !!!"
      puts "---------------------------------------------------------------------"
      puts
      puts "Finished after "+((Time.now) - start).to_s+" Seconds"
      puts "PoW Hash: "+hash_generated
      puts "Nonce used: "+nonce.to_s
      puts
      puts "Sending data..."
      puts

      #Send info to block_found
      response = $miner.send_block_found(last_block_info, hash_generated, merkle_root, target, hash_trnx, nonce, reward, script_sig)

      if (response[:ret].map{|k|k.last}.last) == "success"
        $block = response[:transaction]
      end
      mining = true

      break
    end
    nonce += 1
  end
end
