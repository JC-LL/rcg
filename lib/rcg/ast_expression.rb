module RCG

  class Var
    @@id=-1
    attr_accessor :name,:depth
    def initialize name=nil
      @name=name || "i#{@@id+=1}".to_sym
    end

    def self.reset
      @@id=-1
    end

    def to_s
      @name
    end

    def depth
      @depth||=0
    end
  end

  class Unary
    attr_accessor :op,:expr
    def initialize op,expr
      @op,@expr=op,expr
    end

    def depth
      return @depth if @depth #memoization
      case expr
      when Var
        return 1
      else
        return 1+expr.depth
      end
    end

    def vars
      ary=[]
      case var=expr
      when Var
        ary << var
      else
        ary << expr.vars
      end
      ary.flatten.uniq
    end

    def to_s
      "(#{op} #{expr.to_s})"
    end
  end

  class Binary
    attr_accessor :l,:op,:r
    attr_accessor :depth
    def initialize l,op,r
      @l,@op,@r=l,op,r
    end

    def depth
      return @depth if @depth #memoization
      case l
      when Var
        return 1
      else
        return maxl=1+l.depth
      end
      case r
      when Var
        return 1
      else
        return maxr=1+r.depth
      end
      return @depth=[maxl,maxr].max #memoization
    end

    def vars
      ary=[]
      case l
      when Var
        ary << l
      else
        ary << l.vars
      end
      case r
      when Var
        ary << r
      else
        ary << r.vars
      end
      ary.flatten.uniq
    end

    def to_s
      "(#{l.to_s} #{op} #{r.to_s})"
    end
  end

  OPS=[:and,:or,:xor,:nand,:nor,:not]

end
