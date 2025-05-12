module RCG

  # Wire : not very usefull here!
  class Wire
    @@id=-1
    attr_accessor :name
    def initialize
      @name="w#{@@id+=1}"
    end
  end

  class Port
    attr_accessor :name
    attr_accessor :wire
    attr_accessor :component
    attr_accessor :source,:sinks
    attr_accessor :value
    def initialize name,component
      @name=name
      @component=component
      @sinks=[]
      @source=nil
      #@wire=Wire.new
    end

    def connect target
      puts "     |--[+] connecting #{self} => #{target}"  if $verbose
      self.wire||=Wire.new
      unless @sinks.include?(target)
        @sinks << target
      end
      target.source=self
    end

    def to_s
      "#{component.name}.#{name}"
    end
  end

  class Input < Port
  end

  class Output < Port
  end

  class Circuit
    @@id=-1
    attr_accessor :name
    attr_accessor :inputs,:outputs,:components
    attr_accessor :delay

    def initialize name=nil
      @name=name || "#{self.class}_#{@@id+=1}"
      @inputs,@outputs=[],[]
      @components=[]
    end

    def <<(e)
      case e
      when Input
        @inputs << e unless @inputs.any?{|input| input.name==e.name}
      when Output
        @outputs << e unless @outputs.any?{|output| output.name==e.name}
      when Circuit
        @components << e unless @components.any?{|comp| comp.name==e.name}
      end
    end

    def create i_or_o, name
      case i_or_o
      when :input
        self << port=Input.new(name,self)
      when :output
        self << port=Output.new(name,self)
      end
      port
    end

    def get_port_named name
      ports=[@inputs,@outputs].flatten
      ports.find{|port| port.name==name}
    end

    def get_average_fanout
      port_fanout_h={}
      @inputs.each do |input|
        port_fanout_h[input]=input.sinks.size
      end
      @components.each do |comp|
        comp.outputs.each do |output|
          port_fanout_h[output]=output.sinks.size
        end
      end
      port_fanout_h.values.sum.to_f / port_fanout_h.size
    end

    def get_regs
      @components.select{|comp| comp.is_a?(RCG::Dff)}
    end

    def get_comb_seq
      @components.partition{|comp| comp.is_a?(RCG::Dff)}
    end
  end

  class Gate1 < Circuit
    def initialize
      super
      self << Input.new(:i,self)
      self << Output.new(:f,self)
    end
  end

  class Gate2 < Circuit
    def initialize
      super
      self << Input.new(:i0,self)
      self << Input.new(:i1,self)
      self << Output.new(:f,self)
    end
  end

  class Dff < Circuit
    def initialize
      super
      self << Input.new(:d,self)
      self << Output.new(:q,self)
    end
  end
end
