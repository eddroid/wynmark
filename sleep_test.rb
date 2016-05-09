require_relative 'wynmark.rb'
include WynMarker

OPTIONS = {
  batch: 15,
  warmup: 0,
}

def original_code
  # original code here
  sleep 0.104
end


def new_code
  # new code here
  sleep 0.1
end

orig_marks = warmup_and_mark(
   OPTIONS[:warmup], 
   OPTIONS[:batch]) { original_code }

new_marks = warmup_and_mark(
  OPTIONS[:warmup], 
  OPTIONS[:batch]) { new_code }


graph_results(orig_marks, new_marks)
calculate_significance(orig_marks, new_marks)
