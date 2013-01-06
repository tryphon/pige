module Bundler
  class GemHelper
    protected
    def rubygem_push(path)
      remote_server = "www.tryphon.priv"
      remote_directory = "/var/www/tryphon.eu/download/rubygems"

      gem_file = Dir["pkg/#{name}-*.gem"].sort_by{|f| File.mtime(f)}.last

      command = [].tap do |parts|
        parts << "scp #{gem_file} #{remote_server}:#{remote_directory}/gems"
        parts << "ssh #{remote_server} gem generate_index --directory #{remote_directory}"
      end.join(" && ")
      
      sh command
    end
  end
end

task :push do 
  Bundler::GemHelper.new(".", "pige").send :rubygem_push, nil
end
