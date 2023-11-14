module Rcg

  class Expr

    @@expr={}
    def self.exprs
      @@expr
    end

    def self.gen vars,depth
      @@expr[depth]||=[]
      @@shared=[]
      return vars.sample if depth.zero?
      begin
        expr=[Not,Buf,And,Or,Xor,Nor,Nand,Input,Expr].sample.new
        case expr
        when Input
          expr=vars.sample
        when Binary
          begin
            expr.lhs=Expr.gen(vars,depth-1)
            expr.rhs=Expr.gen(vars,depth-1)
          end while expr.depth!=depth
        when Unary
          expr.expr=Expr.gen(vars,depth-1)
        when Expr #for sharing sub expressions
          expr=(e=@@expr[depth] and e.any?) ? shared=e.sample : Expr.new
          @@shared << shared
          @@shared.uniq!
          puts expr.to_s
        end
      end while expr.depth!=depth
      @@expr[depth] << expr
      return expr
    end

    def depth
      0
    end

    def shared_expr
      nodes.select{|node| @@shared.include?(node)}
    end

    def self.gen_set vars,nb_exprs, depth
      expressions=[]
      expressions << Expr.gen(vars,depth)
      (nb_exprs-1).times do
        expressions << Expr.gen(vars,Array(1..depth).sample)
      end
      expressions
    end
  end

  class Output
    attr_accessor :name
    def initialize name=nil
      @name=name
    end
  end

  class Input < Expr
    attr_accessor :name
    def initialize name=nil
      @name=name
    end

    def depth
      0
    end

    def to_s
      name
    end

    def nodes
      []
    end

    def nb_nodes
      0
    end

    def vars
      [self]
    end
  end

  class Binary < Expr
    attr_accessor :lhs,:rhs
    def initialize l=nil,r=nil
      @lhs,@rhs=l,r
    end

    def depth
      1+[lhs.depth,rhs.depth].max
    end

    def nodes
      [self,lhs.nodes,rhs.nodes].flatten.uniq
    end

    def nb_nodes
      nodes.size
    end

    def to_s
      name=self.class.to_s.downcase.split("::").last
      "(#{lhs.to_s} #{name} #{rhs.to_s})"
    end

    def vars
      [lhs.vars,rhs.vars].flatten.uniq
    end
  end

  class Unary < Expr
    attr_accessor :expr
    def initialize e=nil
      @expr=e
    end

    def depth
      1+(expr.depth)
    end

    def nodes
      [self,expr.nodes].flatten.uniq
    end

    def nb_nodes
      nodes.size
    end

    def to_s
      name=self.class.to_s.downcase.split("::").last
      "(#{name} #{expr.to_s})"
    end

    def vars
      expr.vars.uniq
    end
  end

  class Not < Unary
  end

  class Buf < Unary
  end

  class And < Binary
  end

  class Or < Binary
  end

  class Xor < Binary
  end

  class Nand < Binary
  end

  class Nor < Binary
  end

end
