class Pige::Record

  attr_accessor :begin, :duration, :filename

  def initialize(filename = nil)
    @filename = filename
  end

  def begin
    @begin ||= file_begin
  end

  def before?(time)
    time.nil? or self.end < time or self.begin < time
  end

  def filename_time_parts
    filename.scan(/\d+/).last(5)
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

  def file_duration
    return nil if filename.blank?
    TagLib::FileRef.open(filename) do |file|
      file.audio_properties.length
    end
  rescue Exception => e
    Pige.logger.error "Can't read file duration for #{filename} (#{e.inspect})"
    nil
  end

  def time_range
    Range.new self.begin, self.end
  end

  def end
    @end ||= self.begin + duration if self.begin and duration
  end

  def quality
    case File.extname(filename).downcase
    when ".wav" 
      1
    when ".ogg"
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

end

