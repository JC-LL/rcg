require_relative "../lib/rcg"

params={
  name:           "test_1",
  nb_inputs:      6,
  nb_outputs:     5,
  depth:          6,
  sharing_effort: 40,
  verbose:        false,
}

tool=RCG::Tool.new
netlist=tool.generate_circuit(params)
tool.print_synchrony(netlist)
