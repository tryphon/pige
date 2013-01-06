require 'spec_helper'

describe Pige do
  
  describe "#available_loggers" do
    it "should return a array of loggers" do
      Pige.available_loggers.all? { |logger| logger.should respond_to(:debug) }
    end
  end

end
