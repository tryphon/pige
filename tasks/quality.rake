require 'flay'

require "rake/tasklib"
require 'flay_task'

FlayTask.new(:flay, 200, %w{lib}).tap do |task|
  task.verbose = true
end

require 'flog'
require "rake/tasklib"

# flog_task (2.3.0) ... doesn't provide a working task 
class FlogTask < Rake::TaskLib
  attr_accessor :name
  attr_accessor :dirs
  attr_accessor :threshold
  attr_accessor :verbose

  def initialize name = :flog, threshold = 200, dirs = nil
    @name      = name
    @dirs      = dirs || %w(app bin lib spec test)
    @threshold = threshold
    @verbose   = Rake.application.options.trace

    yield self if block_given?

    @dirs.reject! { |f| ! File.directory? f }

    define
  end

  def define
    desc "Analyze for code complexity in: #{dirs.join(', ')}"
    task name do
      flog = Flog.new
      flog.flog(*dirs)

      flog.report 

      if flog.totals.any? { |m, score| score > threshold }
        raise "Max flog too high! > #{threshold}" 
      end
    end
    self
  end
end

FlogTask.new(:flog, 20, %w{lib})

desc "Runs all code quality metrics"
task :quality => [:flog, :flay]
