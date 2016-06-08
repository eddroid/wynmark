puts "start"

f1 = Fiber.new { 5.times { puts 'hello' } }

f2 = Fiber.new { 5.times { puts 'world'} }

[f1, f2].map(&:resume)

puts "end"
