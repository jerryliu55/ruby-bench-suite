require_relative 'support/benchmark_liquid.rb'
require_relative 'support/theme_runner.rb'

profiler = ThemeRunner.new
profiler.compile_tests

Benchmark.liquid("render") do
  profiler.benchmark_render
end
