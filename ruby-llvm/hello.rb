gem 'ruby-llvm'
require 'llvm/core'
require 'llvm/execution_engine'


m = LLVM::Module.new('hello')

def llvm_str str
  LLVM::ConstantArray.string(str)
end

# generate global string "Hello, World!"
str = "Hello, World!"
llvm_str_type = LLVM.Array(LLVM::Int8, str.size + 1)
llvm_g_str = m.globals.add(llvm_str_type, ".str")
llvm_g_str.initializer = llvm_str(str)

# External Declaration of the `puts` function

arg_types = [LLVM.Pointer(LLVM::Int8)]
cputs = m.functions.add('puts', arg_types, LLVM::Int32)

# Definition of main function
main = m.functions.add('main', [], LLVM::Int32) do |function|
  entryBB = function.basic_blocks.append
  entryBB.build do |builder|
    zero = LLVM.Int(0)

    # GetElementPointer(gep)
    cast210 = builder.gep llvm_g_str, [zero, zero], 'cast210'
    builder.call cputs, cast210
    builder.ret zero
  end
end

m.dump
