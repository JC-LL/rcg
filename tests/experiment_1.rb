require_relative "../lib/rcg"

tool=RCG::Tool.new

ARGV.first.to_i.times do |name|

  params={
    name:           "test_#{name}",
    nb_inputs:      8,
    nb_outputs:     6,
    depth:          10,
    sharing_effort: 40,
    #---------------------------
    gen_tb:         true,
    nb_vectors:     10,
    verbose:        false,
  }

  netlist=tool.generate_circuit(params)

end
