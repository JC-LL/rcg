module Rcg
  class Circuit
    attr_accessor :name
    attr_accessor :components
    def initialize name, components=[]
      @name=name
      @components=components
    end

    def self.gen_from name,expressions=[]
      puts "[+] generating circuit '#{name}' from #{expressions.size} expressions"
      Circuit.new(name)
    end
  end
end
