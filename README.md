  http://tatsu-zine.com/books/llvm

  https://github.com/ruby-llvm/ruby-llvm/tree/master/samples 
  https://github.com/Kmotiko/DummyCCompiler 
  http://kschiess.github.io/parslet/ 
　https://github.com/ruby-llvm/ruby-llvm 
  
  http://www.slideshare.net/cuzic/llvm-23970786

# how to use
## ruby-llvm
```
    cd ruby-llvm
    ruby hello.rb
    ruby hello.rb 2> hello.ll
    lli hello.ll

    ruby hello-run.rb

    ruby factorial.rb
```

## parslet
```
    cd parslet

    ruby calc-llvm.rb '1+2*3+4'
```

## opt-example
```
    cd opt-example

    rake inline.ll
    rake opt[inline]

    rake instcombine.ll
    rake opt[instcombine]

    rake simplifycfg.ll
    rake opt[simplifycfg]

    rake std_pass
    rake o1_pass
    rake o3_pass
```

