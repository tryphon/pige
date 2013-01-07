require 'spec_helper'

describe Pige::Record::Directory do

  let(:index) { Pige::Record::Index.new }
  subject { Pige::Record::Directory.new index, "2012/04-Apr/19-Thu" }

  describe "#path" do
    it "should join index.directory and name" do
      subject.path.should == "#{index.directory}/#{subject.name}"
    end
  end

  describe "#begin" do
    
    it "should use the time in name" do
      subject.begin.should == time("04/19/2012 00:00 UTC")
    end

  end

  describe "#end" do
    
    it "should return the end of the year when name is '2012'" do
      subject.name = "2012"
      subject.end.should == subject.begin.end_of_year
    end

    it "should return the end of the month when name is '2012/12'" do
      subject.name = "2012/12"
      subject.end.should == subject.begin.end_of_month
    end

    it "should return the end of the day when name is '2012/12/31'" do
      subject.name = "2012/12/31"
      subject.end.should == subject.begin.end_of_day
    end

  end

  describe "#before?" do
    
    it "should return true if given date is after begin and end" do
      subject.stub :begin => time("04/19/2012 00:00 UTC"), :time_period => :day
      subject.should be_before(time("04/20/2012 00:00 UTC"))
    end

    it "should return true if given date is after begin and before end" do
      subject.stub :begin => time("04/19/2012 00:00 UTC"), :time_period => :day
      subject.should be_before(time("04/19/2012 12:00 UTC"))
    end

    it "should return true if given date is nil" do
      subject.should be_before(nil)
    end

    it "should return false if given date is before begin and end" do
      subject.stub :begin => time("04/19/2012 00:00 UTC"), :time_period => :day
      subject.should_not be_before(time("04/18/2012 00:00 UTC"))
    end

  end

  describe "#entries" do
    
    it "should ignore dot directories" do
      Dir.stub :entries => [".", "..", "dummy"]
      subject.entries.should == ["dummy"]
    end

  end

  describe "#directories" do

    it "should return a new Directory for each subdirectories" do
      in_a_directory do |directory|
        directory.with "2012/01-Jan/06-Tue/19h00.wav"
        directory.with "2012/02-Fev/06-Tue/19h00.wav"
        directory.with "2012/03-Mar/06-Tue/19h00.wav"

        directory.index_directory("2012").directories.map(&:name).should == %w{2012/01-Jan 2012/02-Fev 2012/03-Mar}
      end    
    end
                            
  end

  describe "records" do

    it "should return Records associated to given files" do
      in_a_directory do |directory|
        directory.with "2012/03-Mar/20-Tue/15h15.wav"
        directory.with "2012/03-Mar/20-Tue/15h20.wav"

        directory.index_directory("2012/03-Mar/20-Tue").records.map(&:filename).should == directory.expand_paths("2012/03-Mar/20-Tue/15h15.wav", "2012/03-Mar/20-Tue/15h20.wav")
      end
    end

    it "should ignore files suffixed with -<n>.wav/ogg" do
      in_a_directory do |directory|
        directory.with "2012/03-Mar/06-Tue/19h10-1.wav"
        directory.with "2012/03-Mar/06-Tue/19h10-1.ogg"
        directory.with "2012/03-Mar/06-Tue/19h05.wav"

        directory.index_directory("2012/03-Mar/06-Tue").records.map(&:filename).should == directory.expand_paths("2012/03-Mar/06-Tue/19h05.wav")
      end
    end

    it "should ignore ogg file when wav is present" do
      in_a_directory do |directory|
        directory.with "2012/03-Mar/06-Tue/19h05.ogg"
        directory.with "2012/03-Mar/06-Tue/19h10.wav"
        directory.with "2012/03-Mar/06-Tue/19h10.ogg"
        directory.with "2012/03-Mar/06-Tue/19h15.wav"

        directory.index_directory("2012/03-Mar/06-Tue").records.map(&:filename).should == directory.expand_paths("2012/03-Mar/06-Tue/19h05.ogg", "2012/03-Mar/06-Tue/19h10.wav", "2012/03-Mar/06-Tue/19h15.wav")
      end
    end

    it "should ignore just modified files" do
      in_a_directory do |directory|
        directory.with "2012/03-Mar/06-Tue/19h10.wav"
        directory.with "2012/03-Mar/06-Tue/19h15.wav", :mtime => Time.now

        directory.index_directory("2012/03-Mar/06-Tue").records.map(&:filename).should == directory.expand_paths("2012/03-Mar/06-Tue/19h10.wav")
      end
    end
    
  end

  describe "#last_record" do

    it "should find last record in directory" do
      in_a_directory do |directory|
        directory.with "2012/03-Mar/20-Tue/15h15.wav"
        directory.with "2012/03-Mar/20-Tue/15h20.wav"

        directory.index_directory("2012/03-Mar/20-Tue").last_record.filename.should == directory.expand_path("2012/03-Mar/20-Tue/15h20.wav")
      end    
    end

    it "should find last record in subdirectories" do
      in_a_directory do |directory|
        directory.with "2012/03-Mar/20-Tue/15h15.wav"
        directory.with "2012/03-Mar/20-Tue/15h20.wav"

        directory.index_directory("2012/03-Mar").last_record.filename.should == directory.expand_path("2012/03-Mar/20-Tue/15h20.wav")
      end    
    end

    it "should find last record before given time" do
      in_a_directory do |directory|
        directory.with "2012/03-Mar/20-Tue/15h15.wav"
        directory.with "2012/03-Mar/20-Tue/15h20.wav"

        directory.with "2012/04-Apr/18-Wed/21h00.wav"
        directory.with "2012/04-Apr/18-Wed/21h05.wav"
        directory.with "2012/04-Apr/18-Wed/21h10.wav"

        directory.index_directory("2012").last_record(time("04/18/2012 00:00 UTC")).filename.should == directory.expand_path("2012/03-Mar/20-Tue/15h20.wav")
      end    
    end
                            
  end
  
end
