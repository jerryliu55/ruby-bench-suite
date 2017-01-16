require_relative 'support/benchmark_liquid.rb'
require_relative 'support/theme_runner.rb'

profiler = ThemeRunner.new

Benchmark.liquid("parse") do
  profiler.compile
end
