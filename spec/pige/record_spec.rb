require 'spec_helper'

describe Record do

  subject { Record.new(tune_file(300)) }

  describe "#filename_time_parts" do

    let(:numbers) { Array.new(10) { |n| n.to_s } }
    
    it "should scan 5 last numbers in filename" do
      subject.filename = numbers.join("-")
      subject.filename_time_parts.should == numbers.last(5)
    end

  end

  describe "#file_begin" do

    it "should return nil if filename_time_parts is empty" do
      subject.stub :filename_time_parts => []
      subject.file_begin.should be_nil
    end
    
    it "should create UTC time from filename_time_parts" do
      subject.stub :filename_time_parts => %w{2012 03 06 16 00}
      subject.file_begin.should == time("03/06/2012 16:00 UTC")      
    end

  end

  describe "#begin" do
    
    it "should use file_begin by default" do
      subject.stub :file_begin => Time.now
      subject.begin.should == subject.file_begin
    end

    it "should use specified begin" do
      subject.begin = (specified_begin = Time.now)
      subject.begin.should == specified_begin
    end

  end

  describe "#duration" do

    it "should use file_duration by default" do
      subject.stub :file_duration => 300
      subject.duration.should == subject.file_duration
    end

    it "should use a specified duration" do
      subject.duration = 300
      subject.duration.should == 300
    end

  end

  describe "#file_duration" do
    
    it "should return audio duration read by TagFile" do
      Record.new(tune_file(300)).should have_duration_of(300.seconds)
    end

    it "should be nil when file isn't found" do
      subject.filename = "dummy"
      subject.file_duration.should be_nil
    end

    it "should be nil when filename isn't defined" do
      subject.filename = nil
      subject.file_duration.should be_nil
    end

    it "should TagLib::FileRef to known file duration" do
      taglib_file = mock(TagLib::FileRef).tap do |file|
        file.stub_chain(:audio_properties, :length).and_return(10)
      end
      
      TagLib::FileRef.should_receive(:open).with(subject.filename).and_yield(taglib_file)
      subject.file_duration.should == 10
    end

    it "should be nil when TagLib::FileRef fails" do
      TagLib::FileRef.stub!(:open).and_raise("error")
      subject.file_duration.should be_nil
    end

  end

  describe "end" do

    let(:begin_date) { Time.now }
    
    it "should be computated from begin and duration when not defined" do
      subject.stub :begin => begin_date, :duration => 300
      subject.end.should == subject.begin + subject.duration
    end

  end

  describe "#time_range" do
    
    it "should return a range with Record#begin and #end" do
      subject.time_range.should == (subject.begin..subject.end)
    end

  end

end

