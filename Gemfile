source 'https://rubygems.org'

# Specify your gem's dependencies in pige.gemspec
gemspec

unless RUBY_VERSION =~ /^1.8/
  gem 'simplecov'
else
  gem "rcov"
end

gem "ruby-prof"

if RUBY_PLATFORM =~ /linux/
  gem 'rb-inotify', '~> 0.8.8'
  gem 'libnotify'
end
