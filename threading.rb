puts "start"

t1 = Thread.new { 5.times { puts "hello" } }

t2 = Thread.new { 5.times { puts "world" } }

[t1, t2].map(&:join)
puts "end"
