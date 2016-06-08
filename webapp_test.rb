require_relative 'wynmark.rb'
include WynMarker
require 'open-uri'

OPTIONS = {
  batch: 20,
  warmup: 0,
}

def original_code
  open("http://localhost:3000/users")
end


def new_code
  open("http://localhost:3000/users")
end

orig_marks = warmup_and_mark(
   OPTIONS[:warmup], 
   OPTIONS[:batch]) { original_code }

print "Press enter when the new app is ready."
gets

new_marks = warmup_and_mark(
  OPTIONS[:warmup], 
  OPTIONS[:batch]) { new_code }


graph_results orig_marks, new_marks

calculate_significance orig_marks, new_marks
