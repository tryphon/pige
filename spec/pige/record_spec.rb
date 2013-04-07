require 'spec_helper'

describe Pige::Record do

  subject { Pige::Record.new(tune_file(300)) }

  describe "#relative_filename" do
    
    it "should return nil if Record has no base_directory" do
      Pige::Record.new("dummy").relative_filename.should be_nil
    end

    it "should return dummy for /path/to/dummy with /path/to base_directory" do
      Pige::Record.new("/path/to/dummy", :base_directory => "/path/to").relative_filename.should == "dummy"
    end

  end

  describe "#filename_time_parts" do

    context "when a relative_filename is available" do
      
      it "should use numbers in relative_filename" do
        subject.stub :relative_filename => "dummy/2012/03/06/16:00:30"
        subject.filename_time_parts.should == %w{2012 03 06 16 00 30}
      end
                                                
    end

    context "without relative_filename" do

      let(:numbers) { Array.new(10) { |n| n.to_s } }

      it "should use numbers in filename" do
        subject.filename = numbers.join("-")
        subject.filename_time_parts.should == numbers
      end

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

    it "should support '/path/1/to/2013/01-Jan/15-Tue/17h11m36.ogg'" do
      subject.base_directory = '/path/1/to'
      subject.filename = '/path/1/to/2013/01-Jan/15-Tue/17h11m36.ogg'
      subject.file_begin.should == time("01/15/2013 17:11:36 UTC")
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
      Pige::Record.new(tune_file(300)).should have_duration_of(300.seconds)
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

  describe "#modified_since" do
    
    it "should return seconds since last file modification" do
      FileUtils.touch subject.filename, :mtime => (Time.now - 30)
      subject.modified_since.should be_within(1).of(30)
    end

  end

  describe "#opened?" do
    
    it "should return true if modified_since is lower than specified min_age" do
      subject.stub :modified_since => 20.seconds
      subject.should be_open(30.seconds)
    end

    context "when no min_age is specified" do
                                             
      it "should return true if modified_since is lower 30 seconds" do
        subject.stub :modified_since => 29.seconds
        subject.should be_open
      end
      
    end

  end

  describe "valid?" do

    before do
      subject.stub :filename_time_parts => %w{2012 03 06 16 00}
    end

    it "should not be valid if empty" do
      subject.stub :empty? => true
      subject.should_not be_valid
    end

    it "should not be valid if open" do
      subject.stub :open? => true
      subject.should_not be_valid
    end

    it "should use option :min_age to invoke open?" do
      subject.should_receive(:open?).with(0).and_return(true)
      subject.valid? :min_age => 0
    end

    it "should not be valid if filename_time_parts have more than 5 parts" do
      subject.stub :filename_time_parts => %w{2012 03 06 16 00 36}
      subject.should_not be_valid
    end

    context "when not empty, open and filename_time_parts have 5 parts" do

      before do
        subject.stub :empty? => false
        subject.stub :open? => false
      end

      it { should be_valid }

    end

  end

end

