module RCG
  class Tool
    def initialize
      banner
    end

    def banner
      puts "-"*70
      puts "RCG: Random Circuit Generator version #{VERSION} -- #{AUTHOR} #{YEAR}"
      puts "-"*70
    end

    # from params, builds and returns a circuit
    def generate_circuit params={}
      name           = params[:name]
      nb_inputs      = params[:nb_inputs]
      nb_outputs     = params[:nb_outputs]
      depth          = params[:depth]
      gen_tb         = params[:gen_tb]
      nb_vectors     = params[:nb_vectors]
      sharing_effort = params[:sharing_effort]
      delay_model    = params[:delay_model]
      $verbose       = params[:verbose]

      expr_gen = ExpressionMaker.new(nb_inputs,sharing_effort)
      checker  = TautologyChecker.new
      puts "[+] creating #{nb_outputs} outputs expressions"

      expressions=nb_outputs.times.collect do |i|
        target_depth=(i==0) ? depth : 1+rand([1,depth].max)
        begin
          expr=expr_gen.run(target_depth)
          ok=checker.check(expr)
        end while !ok
        expr
      end
      puts "[+] tautology checks passed successfully"
      puts "[+] compiling expressions into circuit"
      netlist  = Circuit.new(name)
      compiler = CircuitMaker.new(netlist)

      expressions.each_with_index do |expr,idx|
        puts " |--[+] compiling cone #{idx} : #{expr.to_s}" if $verbose
        netlist << output=Output.new("f#{idx}".to_sym,netlist)
        gate_output=compiler.compile(expr)
        gate_output.connect output
      end

      puts "[+] info about generated circuit"
      puts " |--[+] name             : "+netlist.name
      puts " |--[+] inputs           : "+netlist.inputs.map(&:to_s).join(',')
      puts " |--[+] outputs          : "+netlist.outputs.map(&:to_s).join(',')
      puts " |--[+] #common subexpr  : "+expr_gen.sharing.to_s
      puts " |--[+] #components      : "+netlist.components.size.to_s
      puts " |--[+] avg fanout       : %2.2f" % netlist.get_average_fanout.to_s
      puts " |--[+] dot file         : "+print_dot(netlist)

      puts "[+] generating VHDL circuit   '#{netlist.name}'"
      vhdl=VHDLPrinter.new
      vhdl.gen_gtech(delay_model)
      vhdl.print(netlist,delay_model)
      model="_#{delay_model}" if delay_model
      if gen_tb
        puts "[+] generating VHDL testbench '#{netlist.name}#{model}_tb'"
        vhdl.gen_tb(netlist,nb_vectors,delay_model)
        puts "[+] generating compile script 'compile_script#{model}'"
        vhdl.gen_compile_script(netlist,delay_model)

        puts "[+] running compile script#{model} "
        system("chmod +x compile_script#{model}")
        system("./compile_script#{model}")

        puts "[+] generating gtkwave waveform file"
        vhdl.gen_gtkwave(netlist,delay_model)
        puts "[+] waveform viewing"
        cmd="gtkwave #{netlist.name}#{model}_tb.ghw #{netlist.name}#{model}_tb.sav "
        exec(cmd)
      end
      netlist
    end

    def read_blif filename
      puts "[+] reading blif file '#{filename}'"
      parser=BlifParser.new
      circuit=parser.parse(filename)
    end

    def print_dot netlist
      DotPrinter.new.print(netlist)
    end

    def invert circuit
      CircuitInverter.new.invert(circuit)
    end
  end
end
