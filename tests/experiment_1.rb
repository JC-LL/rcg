require_relative "../lib/rcg"

params={
  name:           "test",
  nb_inputs:      5,
  nb_outputs:     4,
  depth:          5,
  sharing_effort: 40,
  verbose:        false,
}

tool=RCG::Tool.new
netlist=tool.run(params)
