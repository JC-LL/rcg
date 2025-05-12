module RCG

  class VHDLPrinter

    def initialize
      @gtech_files=[]
    end

    def line(n=60)
      "-"*n
    end

    def print circuit,delay_model=nil
      vhdl=Code.new
      vhdl << header
      vhdl.newline
      vhdl << ieee
      vhdl.newline
      model="_#{delay_model}" if delay_model
      vhdl << "library gtech#{model};"
      case delay_model
      when :rise_fall
        vhdl << entity_rise_fall(circuit)
        vhdl.newline
        vhdl << arch_rise_fall(circuit)
      else
        vhdl << entity(circuit)
        vhdl.newline
        vhdl << arch(circuit)
      end
      vhdl.save_as filename="#{circuit.name}.vhd"
      @top_level=filename
    end

    def header
      code=Code.new
      code << line
      code << "-- generated automatically by RCG tool"
      code << line
      code
    end

    def ieee
      code=Code.new
      code << "library ieee;"
      code << "use ieee.std_logic_1164.all;"
      code
    end


    def entity circuit,delay="1 ps"
      code=Code.new
      code << "entity #{circuit.name} is"
      code.indent=2
      code << "generic(DELAY : time := #{delay});" if delay
      code << "port("
      code.indent=4
      circuit.inputs.each do |port|
        code << "#{port.name} : in  std_logic;"
      end
      circuit.outputs.each do |port|
        code << "#{port.name} : out std_logic;"
      end
      code.indent=2
      code << ");"
      code.indent=0
      code << "end entity;"
      code
    end

    def entity_rise_fall circuit,delay="1 ps",capa=0.1e-12
      code=Code.new
      code << "entity #{circuit.name}_rise_fall is"
      code.indent=2
      code << "generic("
      code;indent=4
      code << "Tr     : time := #{delay};" if delay
      code << "Tf     : time := #{delay};" if delay
      code << "C_load : real := #{capa});" if delay

      code << "port("
      code.indent=4
      circuit.inputs.each do |port|
        code << "#{port.name} : in  real range 0.0 to 5.0;"
      end
      circuit.outputs.each do |port|
        code << "#{port.name} : out real range 0.0 to 5.0 := 0.0"
      end
      code.indent=2
      code << ");"
      code.indent=0
      code << "end entity;"
      code
    end

    def arch circuit
      code=Code.new
      code << "architecture structural of #{circuit.name} is"
      code.indent=2
      circuit.inputs.each do |port|
        code << "signal #{port.wire.name} : std_logic;"
      end
      circuit.components.each do |comp|
        comp.outputs.each do |port|
          code << "signal #{port.wire.name} : std_logic;"
        end
      end
      code.indent=0
      code << "begin"
      code.indent=2
      circuit.inputs.each do |port|
        code << "#{port.wire.name} <= #{port.name};"
      end
      circuit.components.each do |component|
        code << instanciate(component)
      end
      circuit.outputs.each do |port|
        driver=port.source.wire
        code << "#{port.name} <= #{driver.name};"
      end
      code.indent=0
      code << "end;"
      code
    end

    def arch_rise_fall circuit
      code=Code.new
      code << "architecture structural of #{circuit.name}_rise_fall is"
      code.indent=2
      circuit.inputs.each do |port|
        code << "signal #{port.wire.name} : real range 0.0 to 5.0;"
      end
      circuit.components.each do |comp|
        comp.outputs.each do |port|
          code << "signal #{port.wire.name} : real range 0.0 to 5.0;"
        end
      end
      code.indent=0
      code << "begin"
      code.indent=2
      circuit.inputs.each do |port|
        code << "#{port.wire.name} <= #{port.name};"
      end
      circuit.components.each do |component|
        code << instanciate(component)
      end
      circuit.outputs.each do |port|
        driver=port.source.wire
        code << "#{port.name} <= #{driver.name};"
      end
      code.indent=0
      code << "end;"
      code
    end

    def instance_name comp
      comp.name.to_s.split("::").last.downcase
    end

    def instanciate comp
      inst_name=instance_name(comp)
      comp_name=comp.class.to_s.split("::").last.downcase
      code=Code.new
      code << "#{inst_name}: entity gtech.#{comp_name}"
      code.indent=4
      code << "port map("
      code.indent=6
      comp.inputs.each do |port|
        driver=port.source.wire.name
        code << "#{port.name} => #{driver},"
      end
      comp.outputs.each do |port|
        code << "#{port.name} => #{port.wire.name},"
      end
      code.indent=4
      code << ");"
      code.indent=2
      code
    end

    def instanciate comp,delay_model=nil
      inst_name=instance_name(comp)
      comp_name=comp.class.to_s.split("::").last.downcase
      code=Code.new
      if delay_model
        delay_model="_#{delay_model}"
      end
      code << "#{inst_name}: entity gtech.#{comp_name}#{delay_model}"
      code.indent=4
      code << "port map("
      code.indent=6
      comp.inputs.each do |port|
        driver=port.source.wire.name
        code << "#{port.name} => #{driver},"
      end
      comp.outputs.each do |port|
        code << "#{port.name} => #{port.wire.name},"
      end
      code.indent=4
      code << ");"
      code.indent=2
      code
    end

    def gen_gtech delay_model=nil
      GTECH.each do |klass|
        gate=klass.new
        gate.name=klass.to_s.split("::").last.downcase
        code=Code.new
        code << header
        code << ieee
        code.newline
        case delay_model
        when :rise_fall
          code << entity_rise_fall(gate)
          code.newline
          code << archi_rise_fall_of(gate)
        else
          code << entity(gate,delay="#{rand(5)} ps")
          code.newline
          code << archi_of(gate)
        end
        code.newline
        if delay_model
          model="_#{delay_model}"
        end
        code.save_as(filename="#{gate.name}#{model}.vhd")
        @gtech_files << filename
      end
    end

    def archi_of gate
      code=Code.new
      code << "architecture equation of #{gate.name} is"
      code << "begin"
      code.indent=2
      case fname=logical_func_of(gate)
      when "or","and","xor","nor","nand"
        code << "f <= i0 #{fname} i1 after DELAY;"
      when "inv"
        code << "f <= not i after DELAY;"
      when "buf"
        code << "f <= i after DELAY;"
      end
      code.indent=0
      code << "end equation;"
      code
    end

    def archi_rise_fall_of gate
      code=Code.new
      code << "architecture bhv of #{gate.name} is"
      code.indent=2
      code << "signal internal_Y : real := 0.0;"
      code << "constant effective_Tr : time := Tr * (1.0 + integer(C_load/0.1e-12)) * 1 ns;"
      code << "constant effective_Tf : time := Tf * (1.0 + integer(C_load/0.1e-12)) * 1 ns;"
      code.indent=0
      fname=logical_func_of(gate)
      code << "begin"
      code.indent=2
      case fname
      when "and","or","xor","nand", "nor"
        code << "process(i0,i1)"
      when "inv","buf"
        code << "process(i)"
      end
      code.indent=4
      code << "variable target_Y   : real;"
      code << "variable start_Y    : real;"
      code << "variable start_time : time;"
      code << "variable slope      : real;"
      code.indent=2
      code << "begin"
      code.indent=4
      code << "--determine target value"
      case fname
      when "or"
        code << "if i0 > 2.5 or i1 > 2.5 then"
      when "and"
        code << "if i0 > 2.5 and i1 > 2.5 then"
      when "xor"
        code << "if i0 > 2.5 xor i1 > 2.5 then"
      when "nand"
        code << "if i0 > 2.5 nand i1 > 2.5 then"
      when "nor"
        code << "if i0 > 2.5 nor i1 > 2.5 then"
      when "inv"
        code << "if i < 2.5 then"
      when "buf"
        code << "if true then --strange because generated automatically"
      else
        raise "ERROR: unknown gate name '#{fname}'"
      end

      code << "    target_f := 5.0;"
      code << "else"#{model}
      code << "    target_f := 0.0;"
      code << "end if;"
      code.newline
      code << "--if target changed"
      code << "  if target_f /= internal_f then"
      code << "    start_f := internal_f;"
      code << "    start_time := now;"
      code.newline
      code << "    -- compute slope"
      code << "    if target_f > start_f then"
      code << "      slope := (target_f - start_f) / (real(effective_Tr)/1 ns);"
      code << "    else"
      code << "      slope := (target_f - start_f) / (real(effective_Tf)/1 ns);"
      code << "    end if;"
      code.newline
      code << "    -- compute output stepwise"
      code << "    for i in 1 to 100 loop"
      code << "       wait for effective_Tr/100 when target_Y > start_Y else effective_Tf/100;"
      code << "       internal_f <= start_f + slope * (real(now - start_time)/1 ns;"
      code << "       f <= internal_f;"
      code << "    end loop;"
      code << "  end if;"
      code << "end process;"
      code.indent=0
      code << "end bhv;"
      code
    end

    def logical_func_of gate
      mdata=gate.name.to_s.match(/(?<func>([a-zA-Z]+))\d*/)
      mdata[:func]
    end

    def gen_tb circuit,nb_vectors,delay_model
      code=Code.new
      code
      code << header
      code << ieee
      code.newline
      code << "entity #{circuit.name}_tb is"
      code << "end entity;"
      code.newline
      code << "architecture bhv of #{circuit.name}_tb is"
      code.indent=2
      code << "constant HALF_PERIOD : time       := 5 ns;"
      code << "signal running       : boolean    := true;"
      code << "signal clk           : std_logic  := '0';"
      code << "signal reset_n       : std_logic  := '0';"
      code.newline
      [circuit.inputs,circuit.outputs].flatten.each do |port|
        code << "signal #{port.name} : std_logic;"
      end
      code << "signal stimuli : std_logic_vector(#{circuit.inputs.size-1} downto 0) := (others =>'0');"
      code.indent=0
      code << "begin"
      code.indent=2
      code << clk_and_reset()
      code << dut(circuit)
      code << stim_process(circuit,nb_vectors)
      code.indent=0
      code << "end bhv;"
      code.save_as "#{circuit.name}_tb.vhd"
    end

    def clk_and_reset
      code=Code.new
      code << "reset_n <= '0','1' after 13 ns;"
      code.newline
      code << "clk     <= not(clk) after HALF_PERIOD when running else clk;"
      code
    end

    def dut circuit
      code=Code.new
      code << line(40)
      code << "-- design under test"
      code << line(40)
      code << "dut: entity work.#{circuit.name}"
      code.indent=2
      code << "port map("
      code.indent=4
      sort_by_id(circuit.inputs).each_with_index do |port,i|
        code << "#{port.name} => #{port.name},"
      end
      sort_by_id(circuit.outputs).each do |port|
        code << "#{port.name} => #{port.name},"
      end
      code.indent=2
      code << ");"
      code.indent=0
      code
    end

    def stim_process circuit,nb_vect=10
      stim_h=gen_random_stimuli(circuit,nb_vect)
      code=Code.new
      code << line(40)
      code << "-- stimuli generation"
      code << line(40)
      code << "stim_p: process"
      code << "begin"
      code.indent=2
      code << "report(\"waiting for reset\");"
      code << "wait until reset_n='1';"
      code << "report(\"starting vector sequence\");"
      nb_vect.times do |i|
        code << "wait until rising_edge(clk);"
        vect=get_vect_at(stim_h,i)
        code << "stimuli <= \"#{vect.join}\";"
      end
      code << "running <= false;"
      code << "wait;--forever"
      code.indent=0
      code << "end process;"
      code.newline
      sort_by_id(circuit.inputs).each_with_index do |port,i|
        code << "#{port.name} <= stimuli(#{i});"
      end
      code
    end

    def get_vect_at stim_h,cycle
      stim_h.map{|k,ary| ary[cycle]}
    end

    def gen_random_stimuli circuit,nb_vect
      StimuliMaker.new.gen_for(circuit,nb_vect)
    end

    def gen_compile_script circuit,delay_model
      code=Code.new
      code << "echo \" |--[+] cleaning\""
      code << "rm -rf *.o #{@top_level}_tb.vhd work*.cf gtech*.cf"
      code << "echo \" |--[+] compiling VHDL GTECH files\""
      @gtech_files.each do |file|
        code << "echo \" |--[+] compiling #{file}\""
        code << "ghdl -a --work=gtech #{file}"
      end
      code << "echo \" |--[+] compiling VHDL top level\""
      code << "echo \" |--[+] compiling #{@top_level}\""
      code << "ghdl -a #{circuit.name}.vhd"
      code << "echo \" |--[+] compiling VHDL testbench\""
      code << "ghdl -a #{circuit.name}_tb.vhd"
      code << "echo \" |--[+] elaborating testbench\""
      code << "ghdl -e #{circuit.name}_tb"
      code << "echo \" |--[+] running testbench\""
      code << "ghdl -r #{circuit.name}_tb --wave=#{circuit.name}_tb.ghw"
      code.save_as "compile_script"
    end

    def gen_gtkwave circuit,delay_model
      code=Code.new
      code << "-==inputs=="
      sort_by_id(circuit.inputs).each do |port|
        code << "top.#{circuit.name}_tb.#{port.name}"
      end
      code << "-==outputs=="
      sort_by_id(circuit.outputs).each do |port|
        code << "top.#{circuit.name}_tb.#{port.name}"
      end
      code << "-==signals=="
      wires=circuit.components.collect do |comp|
        comp.outputs.map(&:wire)
      end.flatten
      sort_by_id(wires).each do |wire|
        code << "top.#{circuit.name}_tb.dut.#{wire.name}"
      end
      code
      code.save_as "#{circuit.name}_tb.sav"
    end

    def sort_by_id ary_named
      h={}
      ary_named.each do |thg|
        id=thg.name.to_s.scan(/\d+/).last.to_i
        h[id]=thg
      end
      h.keys.sort.map{|k| h[k]}
    end
  end
end
