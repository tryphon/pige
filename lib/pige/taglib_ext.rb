require 'taglib'

module TagLib
  class FileRef

    def size
      ::File.size(file.name)
    end

    def audio_properties_with_wav_support
      audio_properties_without_wav_support.tap do |audio_properties|
        if file.name =~ /\.wav$/i and audio_properties.length == 0
          bitrate = audio_properties.bitrate
          bitrate = 1378.125 if bitrate == 1378
          audio_properties.length = (size / (bitrate / 8 * 1024)).round
        end
      end
    end
    alias_method_chain :audio_properties, :wav_support
    
  end

  class AudioProperties

    def length=(length)
      @defined_length = length
    end

    def length_with_writer
      @defined_length or length_without_writer
    end
    alias_method_chain :length, :writer

  end

end
