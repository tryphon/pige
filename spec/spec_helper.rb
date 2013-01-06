require 'rubygems'
require 'bundler/setup'

unless RUBY_VERSION =~ /^1.8/
  require 'simplecov'

  SimpleCov.start do
    add_filter "/spec/"
  end
end

require 'pige'
require 'active_support/core_ext/string/access'

include Pige

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

RSpec.configure do |config|

end
