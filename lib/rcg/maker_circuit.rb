module RCG

  class CircuitMaker
    def initialize netlist
      @netlist=netlist
      @expr_circuit_h={} #subexpr sharing !
    end

    def compile expr
      #puts "compiling #{expr.to_s}" if $verbose
      case var=binary=unary=expr
      when Var
        input=@netlist.inputs.find{|input| input.name==var.name}
        unless input
          @netlist << input=Input.new(var.name,@netlist)
        end
        return input
      when Unary
        gate=@expr_circuit_h[unary]
        unless gate
          case unary.op
          when :not
            @netlist << gate=Inv.new
          when :yes
            @netlist << gate=Buf.new
          end
          @expr_circuit_h[unary]=gate #subexpr sharing !
        end
        sink=gate.get_port_named(:i)
        source=compile(unary.expr)
        source.connect sink
        return gate.get_port_named(:f)
      when Binary
        gate=@expr_circuit_h[binary]
        unless gate
          case binary.op
          when :and
            @netlist << gate=And2.new
          when :or
            @netlist << gate=Or2.new
          when :xor
            @netlist << gate=Xor2.new
          when :nand
            @netlist << gate=Nand2.new
          when :nor
            @netlist << gate=Nor2.new
          end
          @expr_circuit_h[binary]=gate #subexpr sharing !
        end
        sink=gate.get_port_named(:i0)
        source=compile(binary.l)
        source.connect sink
        sink=gate.get_port_named(:i1)
        source=compile(binary.r)
        source.connect sink
        return gate.get_port_named(:f)
      end
    end
  end
end
