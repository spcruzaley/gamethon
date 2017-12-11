#!/usr/bin/ruby

require './miner'

#Object to miner
$miner = Miner.new

#Get all the current b.locks
current_blocks = $miner.get_info_blocks

#Get last block info
last_block_info = $miner.get_last_block(current_blocks)

#Get the current target
target = $miner.get_current_target

#Generate the merkle root from pool
merkle_root = $miner.generate_merkle_root(current_blocks)

#Get the reward (tomar el height de la info del ultimo bloque)
reward = $miner.get_reward(last_block_info)
fee = $miner.get_fees(current_blocks)
reward_and_fee = reward + fee

nonce = Random.new.rand(100000)
#Generar mew hash
#Return hash with hash, nonce & time
hash_generated = $miner.generate_hash(last_block_info, target, merkle_root, nonce)

#Generate hash transaction
hash_trnx = $miner.generate_hash_transaction(last_block_info, reward_and_fee)
# hash previo
# hash generado
# height (last_info.height + 1)
# nonce
# merkle
# target
# hash de la transaccion

#Send info to block_found
response = $miner.send_block_found(last_block_info, hash_generated, merkle_root, target, hash_trnx, nonce, reward)
