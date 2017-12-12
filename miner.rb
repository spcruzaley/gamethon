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

	$api_service = ApiRest.new('testnet3')

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
		puts "Generating hash..."
		return Sha256::sha256_double(
			Utilities::concat_str(
				Constants::PIPE,Constants::VERSION.to_s,data[:hash].to_s,merkle_root,target.to_s,Constants::MESSAGE,nonce.to_s))
	end

	def generate_hash_transaction(data_last_block, reward)
		puts "Generating hash transaction..."
	  coinbase = {
	    inputs: [
	      {
	        prev_hash: [data_last_block[:hash]].pack('H*'),
	        script_sig: [SecureRandom.hex].pack('H*'),
	        vout: [Utilities::int_to_binary(Constants::MINUS_ONE)].pack('H*')
	      }
	    ],
	    outputs: [
	      {
	        value: [Utilities::int_to_binary(reward)].pack('H*'),
	        script_length: [Utilities::int_to_binary(Constants::SCRIPT.length.to_i)].pack('H*'),
	        script: [Constants::SCRIPT].pack('H*')
	      }
	    ]
	  }

	  transaction = {
	    version: [Utilities::int_to_binary(Constants::VERSION)].pack('H*'),
	    inputs_length: [Utilities::int_to_binary(coinbase[:inputs].length.to_i)].pack('H*'),
	    inputs_map_join: coinbase[:inputs].map{|k| k.values}.join,
	    outputs_length: [Utilities::int_to_binary(coinbase[:outputs].length.to_i)].pack('H*'),
	    outputs_map_join: coinbase[:outputs].map{|k| k.values}.join,
	    lock_time: [Utilities::int_to_binary(Constants::LOCK_TIME)].pack('H*')
	  }

		transac = Sha256::sha256_double(transaction.values.join).reverse
		puts "---------------------------------------------------------------------"
		puts "Transaction generated: #{transac}"
		puts "---------------------------------------------------------------------"
	  return transac
	end

	def send_block_found(prev_block_hash, generated_hash, merkle_root, target, hash_trnx, nonce, reward)

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
					vout: Constants::MINUS_ONE_INT,
					script_sig: SecureRandom.hex
				}],
				outputs: [{
					value: reward,
					script: Constants::SCRIPT
				}]
			}]
		}

		puts data_to_send.to_json

		$api_service.query_post(data_to_send, 'block_found')
	end

end
