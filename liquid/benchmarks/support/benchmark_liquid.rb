require 'liquid'
require 'benchmark/ips'
require 'json'

module Benchmark
  module Liquid
    def liquid(label=nil, time: 10, warmup: 5, &block)
      unless block_given?
        raise ArgumentError.new, "block should be passed"
      end

      report = Benchmark.ips(time, warmup, true) do |x|
        x.report(label) { yield }
      end

      entry = report.entries.first
      stddev_percentage = (entry.ips_sd / entry.ips) * 100

      output = {
        label: label,
        version: ::Liquid::VERSION.to_s,
        iterations_per_second: entry.ips,
        iterations_per_second_standard_deviation: entry.ips_sd,
        iterations_per_second_standard_deviation_percentage: stddev_percentage,
        total_allocated_objects_per_iteration: get_total_allocated_objects(&block)
      }.to_json

      puts output
    end

    def get_total_allocated_objects
      if block_given?
        key =
          if RUBY_VERSION < '2.2'
            :total_allocated_object
          else
            :total_allocated_objects
          end

        before = GC.stat[key]
        yield
        after = GC.stat[key]
        after - before
      end
    end
  end

  extend Benchmark::Liquid
end
