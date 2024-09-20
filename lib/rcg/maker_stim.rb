module RCG
  class StimuliMaker
    def gen_for circuit,nb_vect
      puts "[+] generating test vectors"
      stim_h={}
      circuit.inputs.each do |input|
        stim_h[input.name.to_s]=Array.new(nb_vect){rand(2)}
      end
      stim_h
    end
  end
end
