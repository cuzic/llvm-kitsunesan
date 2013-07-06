gem 'ruby-llvm'
require 'llvm/core'
require 'llvm/execution_engine'
require 'llvm/transforms/scalar'
require 'benchmark'

LLVM.init_x86

m = LLVM::Module.new("Factorial")

m.functions.add("fac", [LLVM::Int], LLVM::Int) do |fac, n|
  n.name = "n"
  bb = fac.basic_blocks
  entry = bb.append("entry")
  recur = bb.append("recur")
  result = bb.append("result")
  n_fac_n_1 = nil

  entry.build do |builder|
    test = builder.icmp(:eq, n, LLVM::Int(1), "test")
    builder.cond(test, result, recur)
  end

  recur.build do |builder|
    n_1 = builder.sub(n, LLVM::Int(1), "n-1")
    fac_n_1 = builder.call(fac, n_1, "fac(n-1)")
    n_fac_n_1 = builder.mul(n, fac_n_1, "n*fac(n-1)")
    builder.br(result)
  end

  result.build do |builder|
    fac = builder.phi(LLVM::Int,
                      {entry => LLVM::Int(1),
                        recur => n_fac_n_1 },
                        "fac")
    builder.ret(fac)
  end
end

m.verify
m.dump

puts "--------------------------------------"
engine = LLVM::JITCompiler.new(m)

puts engine.run_function(m.functions["fac"], 6).to_i
