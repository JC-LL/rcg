module RCG
  class TautologyChecker
    def check expr
      puts " |--[+] checking tautology #{expr.to_s}" if $verbose
      vars=expr.vars
      nvars=vars.size
      truth_table={}
      (2**nvars).times do |val_row|
        valuation={}
        vars.each_with_index do |v,i|
          valuation[v]= (val_row[i]==0) ? false:true
        end
        truth_table[valuation]=evaluate(expr,valuation)
      end
      return valid=truth_table.values.uniq.size > 1
    end

    def evaluate expr,valuation={}
      case unary=binary=var=expr
      when Var
        valuation[var]
      when Unary # only not so far
        val_e=evaluate(unary.expr,valuation)
        !val_e
      else
        val_l=evaluate(binary.l,valuation)
        val_r=evaluate(binary.r,valuation)
        case expr.op
        when :and
          val_l and val_r
        when :or
          val_l or val_r
        when :xor
          val_l ^ val_r
        when :nand
          !(val_l and val_r)
        when :nor
          !(val_l or val_r)
        else
          raise "NIY #{expr.op}"
        end
      end
    end
  end
end
