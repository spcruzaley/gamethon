require './constants'

class Utilities

  #Concat several string with the indicated separator
  def self.concat_str(separator, *strings)
  	concatenated_str = ""
    sep_length = separator.length

    strings.each do |word|
      concatenated_str << word << separator
    end

    if sep_length > Constants::ZERO
      return concatenated_str[0..((sep_length*-1)-1)]
    else
      return concatenated_str
    end
  end

  def self.int_to_binary(int)
    return ('%02x' % [int])
  end

end
