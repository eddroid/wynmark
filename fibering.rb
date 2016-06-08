require 'fiber'
puts "start"

f1 = Fiber.new { 
  5.times { puts 'hello'; Fiber.yield }
}
f2 = Fiber.new {
  5.times { puts 'world'; Fiber.yield}
}
fibers = [f1, f2]

loop do # event loop
  break unless fibers.any?(&:alive?)
  fibers.each(&:resume) rescue nil
end

puts "end"
