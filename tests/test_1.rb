require_relative "../lib/rcg"
include Rcg

nb_vars   = 10
nb_exprs  = 20
max_depth = 8

name="`"
names=[]
nb_vars.times{names << name=name.succ}
vars=names.map{|name| Input.new(name)}

puts "=> generating #{nb_exprs} expressions with #{vars.size} vars and with max depth=#{max_depth}"
puts "vars available   : #{vars.map(&:to_s)} (#{vars.size})"
expressions=Rcg::Expr.gen_set(vars,nb_exprs,max_depth)
expressions.each_with_index do |expr,idx|
  puts "-"*100
  expr_str=expr.to_s.size<100 ? expr.to_s : expr.to_s[0..100]+"...<skipped>"
  idx_s=idx.to_s.rjust(6)
  puts "expression #{idx_s}    : #{expr_str} "
  puts "expression depth       : #{expr.depth}"
  puts "number of nodes        : #{expr.nb_nodes}"
  puts "number of shared nodes : #{expr.shared_expr.size}"

  puts "vars used         : #{expr.vars.map(&:to_s).sort} (#{expr.vars.size})"
end

puts "="*100
puts "total number of inputs used : #{expressions.map{|e| e.vars}.flatten.uniq.size}"
puts "max depth                   : #{expressions.map{|e| e.depth}.max}"
puts "total number of nodes       : #{expressions.map{|e| e.nb_nodes}.sum}"

Circuit.gen_from "test1",expressions
