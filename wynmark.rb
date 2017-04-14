# inspired by http://on-ruby.blogspot.com/2006/12/benchmarking-lies-and-statistics.html
%w[benchmark descriptive-statistics gruff command_line_reporter].each { |lib| require lib }

module WynMark
  include CommandLineReporter

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

    table_result(mean, stats.median, stdev, max_diff, min_diff)

    deltas.each { |d|
      if (d > max_diff or d < min_diff)
        puts "Potential outlier #{d} at position #{deltas.index(d)}"
      end
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

  # graph the results in gruff
  def graph_results(orig_marks, new_marks)
    g = Gruff::Dot.new(800)
    g.title = 'WynMark Results'
    orig_marks.length.times { |n|
      g.labels[n] = n.to_s
    }
    g.data("Original Code", orig_marks)
    g.data("New Code", new_marks)

    begin
      g.write('results.png')
    rescue => e
      # better error
      # 
      # via: http://stackoverflow.com/questions/1014506/imagemagickerror-unable-to-read-font-null-null 
      #
      # brew install gs
      if e.message['unable to read font']
        puts "If you're on a Mac, you need to `brew install gs`"
      end
      raise e
    end

    begin
      # mac open image from Terminal
      `open results.png`
    rescue
      # guessing this is Ubuntu's way of opening images from the Terminal
      `gnome-open results.png` rescue nil
    end
  end

  #
  # Prettified statistics result table display.
  #
  NUM_FORMATTER = '%.10f'
  def table_result(mean, median, stdev, max, min) 
    table(border: true) do
      row(header: true) do
        column 'stat', width: 13
        column 'time in seconds', width: 15, align: 'right'
      end
      row do
        column 'mean'
        column NUM_FORMATTER % mean
      end
      row do
        column 'median'
        column NUM_FORMATTER % median
      end
      row do
        column 'stdev'
        column NUM_FORMATTER % stdev
      end
      row do
        column 'max (2stdev)'
        column NUM_FORMATTER % max
      end
      row do
        column 'min (-2stdev)'
        column NUM_FORMATTER % min
      end
    end
  end
end
