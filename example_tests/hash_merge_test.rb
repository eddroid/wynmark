require_relative '../wynmark.rb'
include WynMark

OPTIONS = {
  warmup: 2,
  batch: 102,
}

HASH1 = ("a".."z").zip(1..26).to_h
HASH2 = (1..26).zip("a".."z").to_h

def original_code
  # original code here
  HASH1.merge HASH2
end

def new_code
  # new code here
  HASH1.merge! HASH2
end

orig_marks = warmup_and_mark(
   OPTIONS[:warmup],
   OPTIONS[:batch]) { original_code }

new_marks = warmup_and_mark(
  OPTIONS[:warmup],
  OPTIONS[:batch]) { new_code }


graph_results(orig_marks, new_marks)
calculate_significance(orig_marks, new_marks)
