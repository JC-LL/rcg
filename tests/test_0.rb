require_relative "../lib/rcg"
include Rcg

nb_vars=40
name="`"
names=[]
nb_vars.times{names << name=name.succ}
vars=names.map{|name| Input.new(name)}

expr=Rcg::Expr.gen(vars,depth=4)
puts "expression       : #{expr.to_s}"
puts "expression depth : #{expr.depth}"
puts "number of nodes  : #{expr.nb_nodes}"
puts "vars available   : #{vars.map(&:to_s)} (#{vars.size})"
puts "vars used        : #{expr.vars.map(&:to_s).sort} (#{expr.vars.size})"

expr=Rcg::Expr.gen(vars,depth=2)
puts "expression       : #{expr.to_s}"
puts "expression depth : #{expr.depth}"
puts "number of nodes  : #{expr.nb_nodes}"
puts "shared nodes     : #{expr.shared_expr.map(&:to_s)}"
puts "number of shared nodes  : #{expr.shared_expr.size}"

puts "vars available   : #{vars.map(&:to_s)} (#{vars.size})"
puts "vars used        : #{expr.vars.map(&:to_s).sort} (#{expr.vars.size})"
