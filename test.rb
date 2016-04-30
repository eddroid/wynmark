require 'benchmark'

results = 10.times.to_a.map! {
  Benchmark.realtime { 
    [1, 1, 1].inject(:+) 
  }
}

p results, results.inject(:+)
