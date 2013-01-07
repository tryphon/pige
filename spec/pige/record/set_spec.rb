require 'spec_helper'

describe Pige::Record::Set do

  describe "#file" do
    
    it "should use tmpdir and id to create a fixed filename" do
      subject.stub :tmp_dir => "/tmp", :id => "<id>", :export! => true
      subject.file.should == "/tmp/recordset-<id>.wav"
    end

    it "should export records when file doesn't exist" do
      subject.stub :id => "dummy"
      subject.should_receive :export!
    end

    it "should not export records when file already exists" do
      subject.stub :id => "dummy"
      FileUtils.touch "#{subject.tmp_dir}/recordset-dummy.wav"
      subject.should_not_receive :export!
      subject.file
    end

    after(:each) do
      File.unlink subject.file if File.exists? subject.file
    end

  end
  
  describe "#parse_id" do
    
    it "should read hexadecimal epoch times" do
      Pige::Record::Set.parse_id("4f689210-4f68a020").should == [ time("03/20/2012 14:20 UTC"), time("03/20/2012 15:20 UTC") ]
    end

    it "should return nil if id is invalid" do
      Pige::Record::Set.parse_id("dummy").should be_nil
    end

    it "should return nil if id is nil" do
      Pige::Record::Set.parse_id(nil).should be_nil
    end

    it "should return nil if id is blank" do
      Pige::Record::Set.parse_id("").should be_nil
    end

  end

  describe "#duration" do

    before(:each) do
      subject.stub :records => Array.new(3) { mock(:duration => 300) }
    end
    
    it "should sum record durations" do
      subject.duration.should == subject.records.sum(&:duration)
    end

    it "should nil if one of the durations is nil" do
      subject.stub :records => (subject.records + [mock(:duration => nil)])
      subject.duration.should be_nil
    end

  end

  describe "#begin" do

    let(:first_record_begin) { Time.now }
    
    it "should be the first record's begin" do
      subject.stub :records => [mock("first", :begin => first_record_begin)]
      subject.begin.should == first_record_begin
    end

  end

  describe "#end" do

    let(:last_record_end) { Time.now }
    
    it "should be the last record's begin" do
      subject.stub :records => [mock("first"), mock("last", :end => last_record_end)]
      subject.end.should == last_record_end
    end

  end

  describe "#id" do
    
    it "should use first and last records begin" do
      first_record_begin = time("03/20/2012 14:20 UTC")
      last_record_begin = time("03/20/2012 15:20 UTC")

      subject.stub :records => [mock("first", :begin => first_record_begin), mock("last", :begin => last_record_begin)]
      subject.id.should == "4f689210-4f68a020"
    end

  end

  describe "#push" do
    
    it "should sort records by begin" do
      first_record = mock :begin => 15.minutes.ago
      second_record = mock :begin => 10.minutes.ago

      subject.push second_record
      subject.push first_record

      subject.records.should == [first_record, second_record]
    end

  end

  describe "#export!" do

    let(:filename) { "dummy" }
    
    it "should use export_command with given output file" do
      subject.stub! :export_command => mock(:run! => true)
      subject.export_command.should_receive(:output).with(filename)
      subject.export! filename
    end

  end

  describe "export_command" do

    it "should return Sox::Command" do
      subject.export_command.should be_instance_of(Sox::Command)
    end

    it "should prepare a Sox::Command with record files as input files" do
      subject.stub :records => [ mock(:filename => "record1"), mock(:filename => "record2") ]

      subject.export_command.inputs.map(&:filename).should == %w{record1 record2}
    end
    
  end

end

