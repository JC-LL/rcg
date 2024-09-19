module RCG
  class DotPrinter
    def print circuit
      dot=Code.new
      dot << "digraph #{name=circuit.name}{"
      dot.indent=2
      dot << "graph [rankdir = LR];"
      circuit.inputs.each do |port|
        dot << "#{name_last(port)}[shape=cds,xlabel=\"#{port.name}\"]"
      end
      circuit.outputs.each do |port|
        dot << "#{name_last(port)}[shape=cds,xlabel=\"#{port.name}\"]"
      end
      circuit.components.each do |component|
        comp_name=name_last(component,'::')
        inputs =component.inputs.map {|port| "<#{port.name}>#{port.name}"}.join("|")
        outputs=component.outputs.map{|port| "<#{port.name}>#{port.name}"}.join("|")
        left   ="{#{inputs}}"
        right  ="{#{outputs}}"
        label  ="{#{left}| #{comp_name} |#{right}}"
        dot << "#{comp_name}[shape=record; style=filled;color=cadetblue; label=\"#{label}\"]"
      end
      sources=(circuit.inputs  + circuit.components.map{|c| c.outputs}).flatten
      sources.each do |source|
        source_comp_name=name_last(source.component,'::')
        source_name= source.component==circuit ? source.name : [source_comp_name,source.name].join(":")
        wire=source.wire
        source.sinks.each do |sink|
          sink_comp_name=name_last(sink.component,'::')
          sink_name  = (sink.component==circuit) ? sink.name : [sink_comp_name,sink.name].join(":")
          dot << "#{source_name} -> #{sink_name} [label=\"#{wire.name}\"]"
        end
      end
      dot.indent=0
      dot << "}"
      dot.save_as "#{name}.dot"
    end

    def name_last thing,separator='.'
      thing.name.to_s.split(separator).last
    end
  end
end
