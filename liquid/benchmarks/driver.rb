#
# Liquid Benchmark driver
#
require 'json'
require 'pathname'
require 'optparse'

RAW_URL = ''

class BenchmarkDriver
  def self.benchmark(options)
    self.new(options).run
  end

  def initialize(options)
    @repeat_count = options[:repeat_count]
    @pattern = options[:pattern]
    @local = options[:local]
  end

  def run
    files.each do |path|
      next if !@pattern.empty? && /#{@pattern.join('|')}/ !~ File.basename(path)
      run_single(path)
    end
  end

  private

  def files
    Pathname.glob("#{File.expand_path(File.dirname(__FILE__))}/bm_*")
  end

  def run_single(path)
    script = "ruby #{path}"

    output = measure(script)
    return unless output

    if @local
      puts output
    else
      # endpoint.request(request)
      puts "Posting results to Web UI...."
    end
  end

  def measure(script)
    begin
      results = []

      @repeat_count.times do
        result = JSON.parse(`#{script}`)
        puts "#{result["label"]} #{result["iterations_per_second"]}/ips"
        results << result
      end

      results.sort_by do |result|
        result['iterations_per_second']
      end.last
    rescue JSON::ParserError
      # Do nothing
    end
  end


end

options = {
  repeat_count: 1,
  pattern: [],
  local: false,
}

OptionParser.new do |opts|
  opts.banner = "Usage: ruby driver.rb [options]"

  opts.on("-r", "--repeat-count [NUM]", "Run benchmarks [NUM] times taking the best result") do |value|
    options[:repeat_count] = value.to_i
  end

  opts.on("-p", "--pattern <PATTERN1,PATTERN2,PATTERN3>", "Benchmark name pattern") do |value|
    options[:pattern] = value.split(',')
  end

  opts.on("--local", "Don't report benchmark results to the server") do |value|
    options[:local] = value
  end
end.parse!(ARGV)

BenchmarkDriver.benchmark(options)
