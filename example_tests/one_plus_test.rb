require_relative '../wynmark.rb'
include WynMark

OPTIONS = {
  warmup: 0,
  batch: 100,
}

ARRAY = [1,1,1].freeze
def original_code
  # Put the original code here
  #ARRAY.inject(:+) # avoid garbage collection delays
  
  [1,1,1].inject(:+)
end


def new_code
  # Put the new code here
  1 + 1 + 1
end

orig_marks = warmup_and_mark(
   OPTIONS[:warmup],
   OPTIONS[:batch]) { original_code }

new_marks = warmup_and_mark(
  OPTIONS[:warmup],
  OPTIONS[:batch]) { new_code }


graph_results(orig_marks, new_marks)
calculate_significance(orig_marks, new_marks)
