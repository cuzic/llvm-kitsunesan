require 'parslet' 
 
module Calculator
  class Parser < Parslet::Parser
    rule(:space)  { match('\s').repeat(1) }
    rule(:sp) { space.maybe }

    rule(:integer) { match('[0-9]').repeat(1).as(:int) }

    rule(:add) { integer.as(:left) >> sp >> match('\+') >> sp >> expr.as(:right) }

    rule(:expr) { add | integer }

    root :expr
  end
     
# "1+2+3"
# {:left=>{:int=>"1"@0},
#  :right=>{:left=>{:int=>"2"@2},
#           :right=>{:int=>"3"@4}}}

  class Transformer < Parslet::Transform
    rule(:int => simple(:n)){ n.to_i }

    rule(:left => simple(:l), :right => simple(:r)){ l + r }
  end
end

begin
  parser = Calculator::Parser.new
  p parser.parse("1+2+3")
  p Calculator::Transformer.new.apply(parser.parse("1+2+3"))
rescue Parslet::ParseFailed => e
  puts e, parser.root.error_tree
end
