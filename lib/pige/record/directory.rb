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
      entry.match /\.(wav|ogg)$/ and
        not entry.match /-[0-9]+\.(wav|ogg)$/
    end
  end

  def unmodified_record_files(max_mtime = Time.now - 30)
    record_files.delete_if do |entry|
      (File.mtime(filename(entry)) > max_mtime).tap do |pending_file| 
        Pige.logger.debug "Ignore modified #{filename(entry)}" if pending_file
      end
    end
  end

  def records
    all_records = unmodified_record_files.collect do |entry|
      Pige::Record.new(filename(entry))
    end.delete_if(&:empty?).sort_by(&:begin)

    Pige::Record.uniq all_records
  end

  def last_record(before = nil)
    unless records.empty?
      records.before(before).first
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
