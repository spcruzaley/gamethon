#!/usr/bin/ruby

require 'pry'
require 'digest'
require 'securerandom'
require './apirest'
require './sha256'
require './constants'
require './utilities'

api = ApiRest.new('testnet3')
target = api.query_get('target')
binding.pry
