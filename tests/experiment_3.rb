require_relative "../lib/rcg"

filename=ARGV.first
raise "waiting for blif file !" unless filename

tool=RCG::Tool.new
netlist=tool.read_blif filename
