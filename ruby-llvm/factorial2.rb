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
  recur2 = bb.append("recur2")
  result = bb.append("result")
  ret_one = bb.append("ret_one")
  n_1 = nil
  n_1_fac_n_2 = nil

  zero = LLVM::Int(0)
  one  = LLVM::Int(1)

  entry.build do |builder|
    test = builder.icmp(:eq, n, zero, "test")
    builder.cond(test, ret_one, recur)
  end

  recur.build do |builder|
    n_1 = builder.sub(n, one, "n-1")
    n_1_0 = builder.icmp(:eq, n_1, zero)
    builder.cond(n_1_0, result, recur2)
  end

  recur2.build do |builder|
    n_2 = builder.sub(n, LLVM::Int(2), "n-2")
    fac_n_2 = builder.call(fac, n_2, "fac(n-2)")
    n_1_fac_n_2 = builder.mul(n_1, fac_n_2, "(n-1)*fac(n-2)")
    builder.br(result)
  end

  result.build do |builder|
    phi = builder.phi(LLVM::Int,
                      {recur2 => n_1_fac_n_2,
                        recur => one },
                        "fac")
    n_phi = builder.mul(n, phi, "n*fac(n-1)")
    builder.ret(n_phi)
  end

  ret_one.build do |builder|
    builder.ret(one)
  end
end

m.verify
m.dump

puts "--------------------------------------"
engine = LLVM::JITCompiler.new(m)

puts engine.run_function(m.functions["fac"], 10).to_i
