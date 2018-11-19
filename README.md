# Wynmark

A Ruby performance benchmarker based on Zed Shaw's [Programmers Need To Learn Statistics Or I Will Kill Them All](https://zedshaw.com/archive/programmers-need-to-learn-statistics-or-i-will-kill-them-all/) and Pat Eyler's [Benchmarking, Lies, and Statistics](http://on-ruby.blogspot.com/2006/12/benchmarking-lies-and-statistics.html).

Check `examples_tests/` for examples of how to setup and run a benchmark comparing two blocks of code (or two webapps).

You can configure:
- `sample_size`: The number of samples of each block to measure.
- `rampup_size`: The number of initial samples to ignore to allow the system to reach _steady state_.

You can generate a graph of the samples (`results.png`, created using [gruff](https://github.com/topfunky/gruff)) and statistics tables (using [command_line_reporter](https://github.com/wbailey/command_line_reporter)).

Wynmark will: 
- calculate a winner (the faster block of code) based on _statistical significance_ (`+/-2 * standard_deviation`)
- identify `outliers` (which are probably an indication of a garbage collection delay)

## Installation

[gruff](https://github.com/topfunky/gruff) depends on [rmagick](https://github.com/rmagick/rmagick), which depends on [ImageMagick v6](https://formulae.brew.sh/formula/imagemagick@6), which isn't the latest. So you may need to do this to `bundle` successfully.

```sh
# Terminal
brew install imagemagick@6
PKG_CONFIG_PATH="/usr/local/opt/imagemagick@6/lib/pkgconfig" bundle
```
