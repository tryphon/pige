class Pige::Record::Index

  attr_reader :directory

  @@record_duration = 5.minutes
  cattr_accessor :record_duration

  @@record_directory = "tmp/records"
  cattr_accessor :record_directory

  def initialize(directory = nil)
    @directory = (directory or record_directory)
  end

  # def records
  #   [last_record].compact
  # end

  def normalized_time(time)
    time = time.to_i
    Time.at(time - time%record_duration).utc
  end

  def basename_at(time)
    normalized_time(time).strftime("%Y/%m-%b/%d-%a/%Hh%M")
  end

  def record_at(time)
    filename = Dir.glob("#{directory}/#{basename_at(time)}.{wav,ogg}").first
    return nil unless filename

    record = Record.new(File.expand_path(filename))
    return nil if record.empty?
    
    record
  end

  def previous(record)
    previous_record = record_at(record.begin - record_duration)
    # Ignore previous record without expected duration
    previous_record if complete_record?(previous_record)
  end

  def complete_record?(record)
    return false unless record and record.duration

    duration_delta = record_duration - record.duration
    # record can make 298s or 320s
    duration_delta <= 2 or duration_delta < 0
  end

  def next_record(record)
    record_at(record.begin + record_duration)
  end

  def last_set(before = nil)
    record = last_record(before)
    return nil unless record

    Record::Set.new.tap do |set|
      while record
        set << record
        record = previous(record)
      end
    end
  end

  def sets(options = {})
    count = options[:count]
    min_duration = (options[:min_duration] or 0)
    
    Pige.logger.info "Search sets with count=#{count} and min_duration=#{min_duration}"

    [].tap do |sets|
      set = last_set
      while set and (count.nil? or sets.size < count)
        if set.duration and set.duration > min_duration
          sets.unshift set
        else
          Pige.logger.info "Ignore Record::Set #{set.inspect}"
        end
        set = last_set(set.begin)
      end
    end
  end

  def set(id_or_begin_date, end_date = nil)
    begin_date, end_date =
      if end_date.nil?
        Record::Set.parse_id(id_or_begin_date)
      else
        [id_or_begin_date, end_date]
      end

      record = record_at(begin_date)
      record_set = Record::Set.new.tap do |set|
        while record and record.begin <= end_date
          set << record
          record = next_record(record)
        end
      end
      record_set unless record_set.empty?
    end

    def root_directory
      Pige::Record::Directory.new self, ""
    end

    delegate :last_record, :to => :root_directory

  end
