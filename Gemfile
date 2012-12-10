source 'https://rubygems.org'

# Specify your gem's dependencies in grandprix.gemspec
gemspec

group :test do
  gem "rspec"
end

group :development do
  gem "rb-inotify", :require => false #Notify guard of file changes
  gem "libnotify", :require => false #System notifications integration
  gem "guard-rspec"
end
