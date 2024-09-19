module RCG

  # Generateur d'expressions booleennes de profondeur donnée (depth).
  # On autorise la réutilisation d'une expression commune.
  # Le sharing_effort (0..100) indique un effort de partage de sous-expressions communes dans une expression booléenne.

  class ExpressionMaker
    attr_accessor :sharing
    def initialize nb_vars,sharing_effort
      reset
      @vars=Array.new(nb_vars){Var.new}
      @exprs=@vars.clone
      @sharing_effort=sharing_effort
      @sharing=0
    end

    def reset
      Var.reset
      @exprs=[]
    end

    def get_a_var
      @vars.sample
    end

    # Returns an existing expression whose depth equal _or less_ then the target depth passed as argument.
    # strict_length indicates whether the returned expression must have the indicated depth.
    # This feature allows for unbalanced (l/r) expression generation.
    def pick_expr depth,strict_length
      apply_rand=rand(100) < @sharing_effort
      if apply_rand
        cands=@exprs.select{|expr| strict_length ? expr.depth == depth : expr.depth <= depth}
        if cands.any?
          @sharing+=1
          return cands.sample
        end
      end
      nil
    end

    def run depth
      raise "ERROR : need depth >=1 (here depth=#{depth})" if depth < 1
      op=OPS.sample
      case depth
      when 1 # forced to pick variables
        case op
        when :not
          exp=get_a_var
          @exprs << ret=Unary.new(:not,exp)
        else #binary
          l=get_a_var
          r=get_a_var
          @exprs << ret=Binary.new(l,op,r)
        end
      else # create subexpession(depth-1) (or shorter when depth is already satisfied)
        case op
        when :not
          exp=pick_expr(depth-1,strict_length=true)
          exp||=run(depth-1)
          @exprs << ret=Unary.new(:not,exp)
        else #binary
          l=pick_expr(depth-1,strict_length=true)
          if l
            strict_length=(l.depth < depth ) ? false : true
          end
          r=pick_expr(depth-1,strict_length)
          l||=run(depth-1)
          r||=run(depth-1)
          @exprs << ret=Binary.new(l,op,r)
        end
      end
      ret
    end
  end

end
