require 'spec_helper'

describe Pige::Record::Index do

  describe "#set" do

    let(:begin_date) { Time.now }
    let(:end_date) { begin_date + 300 }
    
    context "with an id" do

      let(:id) { "4f689210-4f68a020" }
      
      it "should parse Set id" do
        Pige::Record::Set.should_receive(:parse_id).and_return([begin_date, end_date])
        subject.set(id)
      end

    end

    context "with begin/end dates" do

      it "should return nil when no record is associated" do
        subject.set(Time.now, Time.now).should be_nil
      end

      it "should find records from begin to end" do
        in_a_directory do |directory|
          directory.with "2012/03-Mar/06-Tue/15h55.wav"
          directory.with "2012/03-Mar/06-Tue/16h00.wav"

          directory.index.set(time("03/06/2012 15:55 UTC"), time("03/06/2012 16:00 UTC")).should have_duration_of(10.minutes)
        end
      end

      it "should include records with includes the begin/end times" do
        in_a_directory do |directory|
          directory.with "2012/03-Mar/06-Tue/15h55.wav"
          directory.with "2012/03-Mar/06-Tue/16h00.wav"

          directory.index.set(time("03/06/2012 15:57 UTC"), time("03/06/2012 16:02 UTC")).should have_duration_of(10.minutes)
        end
      end

    end
    
  end

  describe "#last_set" do

    it "should find a range with 15h55.wav,16h00.wav,16h05.wav" do
      in_a_directory do |directory|
        directory.with "2011/03-Mar/06-Tue/10h00.wav"

        directory.with "2012/03-Mar/06-Tue/15h55.wav"
        directory.with "2012/03-Mar/06-Tue/16h00.wav"
        directory.with "2012/03-Mar/06-Tue/16h05.wav"

        directory.index.last_set.map(&:filename).should == directory.expand_paths("2012/03-Mar/06-Tue/15h55.wav", "2012/03-Mar/06-Tue/16h00.wav", "2012/03-Mar/06-Tue/16h05.wav")
      end
    end

    it "should find a range when day, month and year changes" do
      in_a_directory do |directory|
        directory.with "2011/12-Dec/31-Sat/23h55.wav" 
        directory.with "2012/01-Jan/01-Sun/00h00.wav" 
        directory.with "2012/01-Jan/01-Sun/00h05.wav"

        directory.index.last_set.map(&:filename).should == directory.expand_paths(directory.all_files)
      end
    end

  end

  describe "last_record" do
    
    it "should return the record with the 'bigest' name" do
      in_a_directory do |directory|
        directory.with "2011/03-Mar/06-Tue/19h00.wav"
        directory.with "2012/02-Fev/06-Tue/19h05.wav"
        directory.with "2012/03-Mar/06-Tue/19h10.wav"

        directory.index.last_record.filename.should == directory.expand_path("2012/03-Mar/06-Tue/19h10.wav")
      end
    end

    it "should return nil if no files is found" do
      in_a_directory do |directory|
        directory.index.last_record.should be_nil
      end
    end

    it "should ignore files suffixed with -<n>.wav/ogg" do
      # Ignore files like :
      # <Pige::Record:0xb655ebf8 @filename="/srv/pige/records/2012/04-Apr/20-Fri/08h55-1.wav">
      in_a_directory do |directory|
        directory.with "2012/03-Mar/06-Tue/19h10-1.wav"
        directory.with "2012/03-Mar/06-Tue/19h10-1.ogg"
        directory.with "2012/03-Mar/06-Tue/19h05.wav"

        directory.index.last_record.filename.should == directory.expand_path("2012/03-Mar/06-Tue/19h05.wav")
      end
    end

    it "should ignore files with seconds" do
      # Ignore files like :
      # <Pige::Record:0xb655ebf8 @filename="/srv/pige/records/2012/04-Apr/20-Fri/08h55m32.wav">
      in_a_directory do |directory|
        directory.with "2012/03-Mar/06-Tue/19h10m32.wav"
        directory.with "2012/03-Mar/06-Tue/19h05.wav"

        directory.index.last_record.filename.should == directory.expand_path("2012/03-Mar/06-Tue/19h05.wav")
      end
    end

    it "should accept partial files (duration < 5min)" do
      in_a_directory do |directory|
        directory.with "2012/03-Mar/06-Tue/19h05.wav", :duration => 2.minutes

        directory.index.last_record.filename.should == directory.expand_path("2012/03-Mar/06-Tue/19h05.wav")
      end
    end

    it "should ignore empty file" do
      in_a_directory do |directory|
        directory.with "2012/03-Mar/06-Tue/19h05.wav"
        directory.with "2012/03-Mar/06-Tue/19h10.wav", :size => 0
        directory.index.last_record.filename.should == directory.expand_path("2012/03-Mar/06-Tue/19h05.wav")
      end
    end

    context "when a time constraints is given" do

      it "should return the last record before the given time" do
        in_a_directory do |directory|
          directory.with "2012/03-Mar/06-Tue/18h00.wav"
          directory.with "2012/03-Mar/06-Tue/18h05.wav"

          directory.with "2012/03-Mar/06-Tue/19h00.wav"
          directory.with "2012/03-Mar/06-Tue/19h05.wav"
          
          directory.index.last_record(time("03/06/2012 19:00 UTC")).filename.should == directory.expand_path("2012/03-Mar/06-Tue/18h05.wav")
        end
      end

    end
  end

  describe "#sets" do
    
    it "should return last_set" do
      pending "Return 'all' available sets"
      subject.stub :last_set => mock("last_set")
      subject.sets.should == [subject.last_set]
    end

    it "should return the last record before the given time" do
      in_a_directory do |directory|
        directory.with "2012/03-Mar/06-Tue/18h00.wav"
        directory.with "2012/03-Mar/06-Tue/18h05.wav"
        
        directory.with "2012/03-Mar/06-Tue/19h00.wav"
        directory.with "2012/03-Mar/06-Tue/19h05.wav"
          
        directory.index.sets.map(&:id).should == [ "4f5650a0-4f5651cc", "4f565eb0-4f565fdc" ]
      end
    end

    it "should ignore empty/invalid records" do
      in_a_directory do |directory|
        directory.with "2012/03-Mar/06-Tue/18h00.wav"
        directory.with "2012/03-Mar/06-Tue/18h05.wav"

        directory.with "2012/03-Mar/06-Tue/18h35.wav", :size => 0
        
        directory.with "2012/03-Mar/06-Tue/19h00.wav"
        directory.with "2012/03-Mar/06-Tue/19h05.wav"
          
        directory.index.sets.map(&:id).should == [ "4f5650a0-4f5651cc", "4f565eb0-4f565fdc" ]
      end
    end

    it "should ignore records with seconds" do
      in_a_directory do |directory|
        directory.with "2012/03-Mar/06-Tue/18h00.wav"
        directory.with "2012/03-Mar/06-Tue/18h05.wav"

        directory.with "2012/03-Mar/06-Tue/18h35m32.wav"
        
        directory.with "2012/03-Mar/06-Tue/19h00.wav"
        directory.with "2012/03-Mar/06-Tue/19h05.wav"
          
        directory.index.sets.map(&:id).should == [ "4f5650a0-4f5651cc", "4f565eb0-4f565fdc" ]
      end
    end

    it "should support partial records" do
      in_a_directory do |directory|
        directory.with "2012/03-Mar/06-Tue/18h00.wav"
        directory.with "2012/03-Mar/06-Tue/18h05.wav"

        directory.with "2012/03-Mar/06-Tue/18h35.wav", :duration => 2.minutes
        
        directory.with "2012/03-Mar/06-Tue/19h00.wav"
        directory.with "2012/03-Mar/06-Tue/19h05.wav"

        directory.with "2012/03-Mar/06-Tue/19h15.wav", :duration => 2.minutes
          
        directory.index.sets.map(&:id).should == ["4f5650a0-4f5651cc", "4f5658d4-4f5658d4", "4f565eb0-4f565fdc", "4f566234-4f566234"]
      end
    end

    it "should ignore Record::Sets shorter than min_duration" do
      in_a_directory do |directory|
        directory.with "2012/03-Mar/06-Tue/18h00.wav"
        directory.with "2012/03-Mar/06-Tue/18h05.wav"

        directory.with "2012/03-Mar/06-Tue/18h35.wav", :duration => 2.minutes
        
        directory.with "2012/03-Mar/06-Tue/19h00.wav"
        directory.with "2012/03-Mar/06-Tue/19h05.wav"
          
        directory.index.sets(:min_duration => 3.minutes).map(&:id).should == ["4f5650a0-4f5651cc", "4f565eb0-4f565fdc"]
      end
    end

  end

end
