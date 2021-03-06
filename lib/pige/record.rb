class Pige::Record

  attr_accessor :begin, :duration, :filename, :base_directory

  def initialize(filename = nil, options = {})
    # Pige.logger.debug "Open record #{filename}"
    self.filename = filename
    self.base_directory = options[:base_directory]
  end

  def begin
    @begin ||= file_begin
  end

  def before?(time)
    time.nil? or self.end < time or self.begin < time
  end

  def relative_filename
    if base_directory and filename =~ %r{^#{base_directory}/(.*)$}
      $1
    end
  end

  def valid?(options = {})
    options = { :min_age => 30 }.merge(options)

    return false if filename_time_parts.size != 5
    return false if open?(options[:min_age])
    return false if empty?

    true
  end

  def open?(min_age = 30.seconds)
    modified_since < min_age
  end

  def modified_since
    Time.now - File.mtime(filename)
  end

  def filename_time_parts
    (relative_filename ? relative_filename : filename).scan(/\d+/)
  end

  def file_begin
    Time.utc(*filename_time_parts) unless filename_time_parts.empty?
  end

  def duration
    @duration ||= file_duration
  end

  def empty?
    duration.nil? or duration.zero?
  end

  def quickwav_file_duration
    sample_count = [File.size(filename) - 44, 0].max
    sample_count / 44100 / 4.0
  end

  def taglib_file_duration
    TagLib::FileRef.open(filename) do |file|
      file.audio_properties.length unless file.null?
    end
  rescue Exception => e
    Pige.logger.error "Can't read file duration for #{filename} (#{e.inspect})"
    nil
  end

  def file_duration
    return nil if filename.blank?

    @file_duration ||=
      if file_extension == "wav"
        quickwav_file_duration
      else
        taglib_file_duration
      end
  end

  def time_range
    Range.new self.begin, self.end
  end

  def end
    @end ||= self.begin + duration if self.begin and duration
  end

  def file_extension
    @file_extension ||= File.extname(filename).downcase[1..-1]
  end

  def quality
    case file_extension
    when "wav"
      1
    when "ogg"
      0.8
    end
  end

  def self.uniq(records)
    records = records.dup
    high_quality_records = {}

    records.each do |record|
      existing_record = high_quality_records[record.begin]
      if existing_record.nil? or record.quality > existing_record.quality
        high_quality_records[record.begin] = record
      end
    end

    records & high_quality_records.values
  end

  def self.human_name
    I18n.translate :record, :scope => [:activerecord, :models]
  end

end
