class Sha256

  #Generates a sha256 hash
  def self.sha256_simple(message)
  	return Digest::SHA256.hexdigest (message)
  end

  #Generates a double sha256 hash
  def self.sha256_double(message)
  	return Digest::SHA256.hexdigest (Digest::SHA256.digest (message))
  end

end
