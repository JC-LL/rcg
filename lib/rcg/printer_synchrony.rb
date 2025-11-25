module RCG

  class SynchronyPrinter

    def initialize
      @gtech_files=[]
    end

    def line(n=60)
      "# "+"="*n
    end

    def header
      code=Code.new
      code << line
      code << "#          generated automatically by RCG tool"
      code << line
      code
    end

    def print circuit,expressions
      puts "[+] generating synchrony code"
      syc=Code.new
      syc << header
      syc << "circuit #{circuit.name}"
      syc.indent=2
      circuit.inputs.each do |input|
        syc << "input #{input.name} : bit"
      end
      circuit.outputs.each do |output|
        syc << "output #{output.name} : bit"
      end

      expressions.each_with_index do |expr,idx|
        syc << "#{circuit.outputs[idx].name.to_s} = #{expr.to_s}"
      end
      syc.indent=0
      syc << "end"
      syc.save_as filename="#{circuit.name}.syc"
    end

  end
end
