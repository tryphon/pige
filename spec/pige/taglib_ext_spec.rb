require 'spec_helper'

describe TagLib::FileRef do

  let(:file) { tune_file }
  subject { TagLib::FileRef.new file }

  describe "#audio_properties_with_wav_support" do

    let(:mp3_file_ref) { TagLib::FileRef.new tune_file(60, :mp3) }
    let(:wav_file_ref) { TagLib::FileRef.new tune_file(60, :wav) }
    
    it "should change length when file isn't a wav file" do
      mp3_file_ref.stub :audio_properties_without_wav_support => mock(:length => 0)
      mp3_file_ref.audio_properties.length.should be_zero
    end

    it "should change length when not zero" do
      wav_file_ref.stub :audio_properties_without_wav_support => mock(:length => 666)
      wav_file_ref.audio_properties.length.should == 666
    end

    it "should change length when file is wav and length is zero" do
      TestAudioProperties = Struct.new(:length, :bitrate)
      wav_file_ref.stub :audio_properties_without_wav_support => TestAudioProperties.new(0, 1378)
      wav_file_ref.audio_properties.length.should == 60
    end

    it "should not break default implementation" do
      mp3_file_ref.audio_properties_without_wav_support.length.should == 60
    end

  end

  describe "#size" do
    
    it "should return file size" do
      subject.size.should == File.size(file)
    end

  end

end
