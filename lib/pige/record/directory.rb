class Pige::Record::Directory

  attr_accessor :index, :name

  def initialize(index, name)
    @index, @name = index, name
  end

  def path
    @path ||= File.join index.directory, name
  end

  def filename_time_parts
    @filename_time_parts ||= name.scan(/\d+/)
  end

  def begin
    @begin ||= Time.utc *filename_time_parts
  end

  def time_depth
    filename_time_parts.size
  end

  @@time_periods = [:year, :month, :day]
  def time_period
    @@time_periods[time_depth-1]
  end

  def end
    @end ||= self.begin.send("end_of_#{time_period}")
  end

  def before?(time)
    time.nil? or self.end < time or self.begin < time
  end

  def entries
    @entries ||= Dir.entries(path).delete_if do |entry|
      %w{. ..}.include? entry
    end
  end

  def filename(entry)
    File.join index.directory, name, entry
  end

  def directories
    entries.select do |entry|
      File.stat(filename(entry)).directory?
    end.collect do |directory|
      self.class.new(index, File.join(name, directory))
    end.sort_by(&:begin)
  end

  def files
    entries.select do |entry|
      File.stat(filename(entry)).file?
    end
  end

  def record_files
    files.select do |entry|
      entry.match /\.(wav|ogg)$/
    end
  end

  def record(entry)
    Pige::Record.new filename(entry), :base_directory => index.directory
  end

  def records
    all_records = record_files.collect do |entry|
      record(entry)
    end.select(&:valid?).sort_by(&:begin)

    Pige::Record.uniq all_records
  end

  def last_record(before = nil)
    current_records = records

    unless current_records.empty?
      current_records.before(before).first
    else
      self.class.last_record_in(directories, before)
    end
  end

  def self.last_record_in(directories, before = nil)
    directories.before(before).first_value do |directory|
      directory.last_record(before)
    end
  end

end
