# inspired by http://on-ruby.blogspot.com/2006/12/benchmarking-lies-and-statistics.html
%w[benchmark descriptive-statistics gruff].each { |lib| require lib }

module WynMarker
  def marks(batch_size)
    batch_size.times.to_a.map! do
      Benchmark.realtime { yield }
    end
  end

  def warmup_and_mark(warmup_count, batch_size)
    arr = marks(batch_size) { yield }
    # ignore initial warmup marks
    arr.shift(warmup_count)
    arr
  end

  def calculate_significance(orig_marks, new_marks)
    # Pairwise difference between marks
    deltas = orig_marks.zip(new_marks).map { |orig, new|
      orig - new
    }

    stats = DescriptiveStatistics::Stats.new(deltas)
    mean = stats.mean
    stdev = stats.standard_deviation

    max_diff = mean + 2 * stdev
    min_diff = mean - 2 * stdev

    p 'mean', mean, 
      'median', stats.median, 
      'stdev', stdev, 
      '2stdev max', max_diff, 
      '-2stdev min', min_diff

    deltas.each { |d|
      puts "Outlier? #{d} at #{deltas.index(d)}" if (d > max_diff or d < min_diff)
    }

    if min_diff <= 0 and max_diff <= 0
      puts "Original code is better"
      return -1
    elsif min_diff <= 0 and max_diff >= 0
      puts "There is no statistically significant difference."
      return 0
    else
      puts "New code is better."
      return 1
    end
  end

  # installation instructions for gruff:
  # 
  # brew install gs
  # gem install gruff
  def graph_results(orig_marks, new_marks)
    g = Gruff::Dot.new(800)
    g.title = 'WynMark Results'
    orig_marks.length.times { |n|
      g.labels[n] = n.to_s
    }
    g.data("Original Code", orig_marks)
    g.data("New Code", new_marks)
    g.write('results.png')
    `open results.png`
  end
end
