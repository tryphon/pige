require "pige/version"

require 'active_support/core_ext/module/attribute_accessors'
require 'logger'

module Pige

  def self.available_loggers
    [].tap do |logger|
      logger << Rails.logger if defined?(Rails)
      logger << Logger.new($stderr)
    end.compact
  end

  mattr_accessor :logger
  def self.logger
    @@logger ||= available_loggers.first
  end

end

require 'tmpdir'
require 'sox'

require 'active_support/core_ext/module/aliasing'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/numeric/time'
require 'active_support/values/time_zone'
require 'active_support/core_ext/enumerable'

require 'pige/core_ext'
require 'pige/taglib_ext'
require 'pige/record'

require 'pige/record/set'
require 'pige/record/index'
require 'pige/record/directory'
