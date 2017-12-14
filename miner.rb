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

class Miner

	def initialize(testnet)
		$api_service = ApiRest.new(testnet)
	end

	def get_info_blocks
		return $api_service.get_blocks
	end

	def get_last_block(block)
		return block[block.length-1]
	end

	def get_current_target
		return $api_service.get_last_target
	end

	def get_pool_info
		return $api_service.get_pool_info
	end

	def merge_hash(hashA, hashB)
	  #binding.pry
	  tempo = hashA.concat(hashB)
	  hash = Digest::SHA256.hexdigest (Digest::SHA256.digest (tempo))
	  return hash
	end

	def generate_merkle_root(obj)
	  if(obj.length == 1)
	    return obj[0]
	  end

	  if(obj.length % 2 != 0)
	    obj.push(obj[-1])
	  end

	  new_arr = Array.new
	  i = 0
	  while i < obj.length do
	    hashA = obj[i]
	    hashB = obj[i+1]
	    i += 2
	    new_arr.push(merge_hash(hashA, hashB))
	  end

	  return generate_merkle_root(new_arr)
	end

	def get_reward(data)
		puts "Getting reward..."
		reward = Constants::REWARD_NETWORK.to_i >> (data[:height] / Constants::HALVING_COUNT)

		return reward
	end

	def get_fees(data)
		puts "Generating fees..."
		input_amounts = data.map{|k|k[:transactions].map{|v|v[:inputs].map{|w|w[:amount]}}}.map(&:last).reduce(:+).reduce(:+)
		output_amounts = data.map{|k|k[:transactions].map{|v|v[:outputs].map{|w|w[:value]}}}.map(&:last).reduce(:+).reduce(:+)

		fee = input_amounts - output_amounts

		if fee < 0
			puts "****************************************"
			puts "WARNING: Fee amount less than zero"
			puts "****************************************"
		end
		return fee
	end

	def generate_hash(data, target, merkle_root, nonce)
		return Sha256::sha256_double(
			Utilities::concat_str(
				Constants::PIPE,Constants::VERSION.to_s,data[:hash].to_s,merkle_root,target.to_s,Constants::MESSAGE,nonce.to_s))
	end

	def generate_hash_transaction(reward, script_sig)
		puts "Generating hash transaction..."

		coinbase = [
			inputs: [
					[Constants::TRNX_ZERO].pack('H*'),
					[script_sig].pack('H*'),
		      Constants::MINUS_ONE #vout
			],
			outputs: [
					reward,
					[Constants::SCRIPT].pack('H*').length,
				  [Constants::SCRIPT].pack('H*')
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
		puts "---------------------------------------------------------------------"
		puts "Transaction generated: #{transac}"
		puts "---------------------------------------------------------------------"
	  return transac
	end

	def send_block_found(prev_block_hash, generated_hash, merkle_root, target, hash_trnx, nonce, reward, script_sig)

		data_to_send = {
			prev_block_hash: prev_block_hash[:hash],
			hash: generated_hash,
			height: prev_block_hash[:height].to_i + 1,
			message: Constants::MESSAGE,
			nonce: nonce,
			nickname: Constants::NICKNAME,
			merkle_root: merkle_root,
			used_target: target,
			transactions: [{
				hash: hash_trnx,
				inputs: [{
					prev_hash: Constants::TRNX_ZERO,
					vout: -1,
					script_sig: script_sig
				}],
				outputs: [{
					value: reward,
					script: Constants::SCRIPT
				}]
			}]
		}

		ret = $api_service.query_post(data_to_send, 'block_found')

		new_block = {
			transaction: data_to_send,
			ret: ret
		}

		return new_block
	end

end
