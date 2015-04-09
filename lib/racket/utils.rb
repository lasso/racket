module Racket
  class Utils
    def self::class_from_string(str)
      const_get(str.gsub(/(^\w|_\w)/) { |match| match[-1].upcase })
    end
  end
end
