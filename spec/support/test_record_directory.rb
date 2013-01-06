class TestDirectory

  def self.open
    new.tap do |directory|
      begin
        yield directory
      ensure
        directory.clear
      end
    end
  end

  attr_accessor :directory

  def initialize
    self.directory = Dir.mktmpdir
  end

  def clear
    FileUtils.rm_rf directory
  end

  def all_files
    @all_files ||= []
  end

  def with(name, options = {})
    default_options = { :duration => 300, :format => File.extname(name).from(1) }
    options = default_options.merge(options)

    target = "#{directory}/#{name}"

    FileUtils.mkdir_p File.dirname(target)

    unless options[:size]
      tune_file = tune_file(options[:duration], options[:format])
      unless options[:mtime]
        FileUtils.ln_sf tune_file, target
      else
        FileUtils.cp tune_file, target
      end
    else
      File.open(target, "w") { |f| f.write IO.read("/dev/zero", options[:size]) }
    end

    unless options[:mtime]
      # Make file older to not ignore it
      mtime_30_seconds_ago = Time.now - 30
      File.utime(mtime_30_seconds_ago, mtime_30_seconds_ago, target) if File.mtime(target) > mtime_30_seconds_ago
    else
      File.utime(options[:mtime], options[:mtime], target)
    end

    all_files << name
    name
  end

  def index
    @index ||= Record::Index.new(directory)
  end

  def index_directory(name)
    Record::Directory.new index, name
  end

  def expand_path(name)
    File.expand_path(name, directory)
  end

  def expand_paths(*names)
    names.flatten.map { |name| expand_path(name) }
  end

end

def in_a_directory(&block)
  TestDirectory.open(&block)
end
