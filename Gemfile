source 'https://rubygems.org'

# Specify your gem's dependencies in pige.gemspec
gemspec

# TagLib 0.5.0 requires tagc0 1.7
gem "taglib-ruby", "~> 0.4.0"

unless RUBY_VERSION =~ /^1.8/
  gem 'simplecov' 
else 
  gem "rcov"
end

if RUBY_PLATFORM =~ /linux/
  gem 'rb-inotify', '~> 0.8.8'
  gem 'libnotify'
end
