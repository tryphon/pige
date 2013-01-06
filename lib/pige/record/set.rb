class Pige::Record::Set

  attr_accessor :records

  def initialize(records = [])
    @records = records
  end

  def push(record)
    @records.push record
    @records = @records.sort_by &:begin

    self
  end
  alias_method :<<, :push

  def begin
    records.first.begin
  end

  def end
    records.last.end
  end

  include Enumerable
  delegate :each, :empty?, :to => :records

  def duration
    durations = records.map(&:duration)
    durations.sum unless durations.any?(&:nil?)
  end

  def export!(filename)
    Pige.logger.debug "Export #{records.inspect}"
    export_command.tap do |sox|
      sox.output filename
    end.run!
  end

  def export_command
    Sox::Command.new do |sox|
      records.each do |record|
        sox.input record.filename
      end
    end
  end

  @@tmp_dir = Dir::tmpdir
  cattr_accessor :tmp_dir

  def file
    @file ||= "#{tmp_dir}/recordset-#{id}.wav".tap do |file|
      export! file unless File.exists?(file)
    end
  end

  def id
    @id ||= [records.first, records.last].map { |record| record.begin.to_i.to_s(16) }.join('-')
  end
  alias_method :to_param, :id

  def self.parse_id(id)
    if id =~ /\A([0-9a-f]+)-([0-9a-f]+)\Z/i
      [ $1, $2 ].map { |s| Time.at(s.to_i(16)).utc }
    end
  end

end
