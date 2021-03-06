require_relative '../wynmark.rb'
include WynMark
require 'open-uri'

OPTIONS = {
  warmup: 1, # you'll probably need to warmup
  batch: 21,
}

URL = "http://localhost:3000/todos"

def original_code
  open(URL) # avoid string gc delays
end


def new_code
  open(URL)
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
