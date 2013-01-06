RSpec::Matchers.define :have_duration_of do |expected|
  match do |actual|
    actual.duration.to_i == expected
  end
end
