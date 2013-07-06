gem 'ruby-llvm'
require 'llvm/core'
require 'parslet' 
require 'fiber'
require 'pp'
 
module Calculator
  class Parser < Parslet::Parser
    rule(:space)  { match('\s').repeat(1) }
    rule(:sp) { space.maybe }

    rule(:integer) { match('[0-9]').repeat(1).as(:int) }

    rule(:mul) {
      integer.as(:left) >> sp >> match('[*/]').as(:op) >>
      sp >> multiplication.as(:right)
    }

    rule(:add) {
      multiplication.as(:left) >> sp >> match('[+-]').as(:op) >>
      sp >> addition.as(:right)
    }

    rule(:multiplication) { mul | integer }

    rule(:addition) { add | multiplication }

    rule(:expression) { addition.as(:expr) }

    root :expression
  end

  class LLVMBuilder
    def initialize
      @fiber = Fiber.new do
        @module = LLVM::Module.new("calculator")

        @module.functions.add("add", [], LLVM::Int) do |f,|
          bb = f.basic_blocks.append("entry")
          bb.build do |builder|
            building_loop builder
          end
        end
      end
      @fiber.resume
    end

    def building_loop builder
      llvm_ir = nil
      loop do
        op, l, r = Fiber.yield llvm_ir
        case op
        when "+"
          llvm_ir = builder.add l, r
        when "-"
          llvm_ir = builder.sub l, r
        when '*'
          llvm_ir = builder.mul l, r
        when "/"
          llvm_ir = builder.sdiv l, r
        when :exit
          llvm_ir = builder.ret l
          break
        end
      end
    end


    def int n
      LLVM.Int n.to_i
    end

    def calc op, l, r
      @fiber.resume op, l, r
    end

    def ret x
      @fiber.resume :exit, x
    end

    def dump
      @module.dump
    end
  end
     
  class LLVMTransformer <Parslet::Transform
    b = @@builder = LLVMBuilder.new

    rule(:int => simple(:n)){
      b.int n
    }

    rule(:left  => simple(:l),
         :right => simple(:r),
         :op    => simple(:op)){
      b.calc op, l, r
    }

    rule(:expr => simple(:x)){
      b.ret x
    }

    def do(tree)
      apply(tree)
      @@builder.dump
    end
  end

end

if $0 == __FILE__
  expr = ARGV.shift
  expr ||= "2013 + 7 / 6"
  begin
    parser = Calculator::Parser.new
    parsed = parser.parse(expr)
    pp parsed
  rescue Parslet::ParseFailed => e
    puts e, parser.root.error_tree
  end
  t = Calculator::LLVMTransformer.new
  t.do(parsed)
end
