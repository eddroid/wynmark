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
    table_stats 'Original', orig_marks
    table_stats 'New', new_marks

    # Pairwise difference between marks
    #   normalize the distribution around 0
    deltas = orig_marks.zip(new_marks).map { |orig, new|
      orig - new
    }
    stats = table_stats 'Deltas', deltas

    # edges of the distribution
    top = stats[:top]
    bottom = stats[:bottom]

    deltas.each { |d|
      if (d > top or d < bottom)
        puts "Potential outlier #{d} at position #{deltas.index(d)}"
      end
    }

    if bottom <= 0 and top <= 0
      puts "Original code is better"
      return -1
    elsif bottom <= 0 and top >= 0
      puts "There is no statistically significant difference."
      return 0
    else
      puts "New code is better."
      return 1
    end
  end

  def table_stats(title, marks)
    stats = calc_stats marks
    table_result(title, stats[:mean], stats[:median], stats[:standard_deviation], 
                 stats[:top], stats[:bottom])
    stats
  end

  def calc_stats(marks)
    stats = DescriptiveStatistics::Stats.new(marks)

    # statistical significance boundaries
    stddev = stats.standard_deviation
    mean = stats.mean
    top = mean + 2*stddev
    bottom = mean - 2*stddev

    {mean: stats.mean, median: stats.median, 
     standard_deviation: stddev, top: top, bottom: bottom}
  end

  # graph the results in gruff
  DEFAULT_GRAPH_WIDTH = 800 # pixels
  def graph_results(orig_marks, new_marks)
    g = Gruff::Dot.new(DEFAULT_GRAPH_WIDTH)
    g.title = 'WynMark Results'
    orig_marks.length.times { |n|
      g.labels[n] = n.to_s
    }
    g.data("Original Code", orig_marks)
    g.data("New Code", new_marks)

    begin
      g.write('results.png')
    rescue => e
      # generate a better error
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
      # but I haven't tested it
      `xdg-open results.png` rescue nil
    end
  end

  #
  # Prettified statistics result table display.
  #
  NUM_FORMATTER = '%.10f'
  def table_result(title, mean, median, stdev, top, bottom) 
    puts title
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
        column '+2stddev'
        column NUM_FORMATTER % top
      end
      row do
        column '-2stddev'
        column NUM_FORMATTER % bottom
      end
    end
  end
end
