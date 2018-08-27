source 'https://rubygems.org'
gemspec

gem 'rake'
gem 'actionpack', '~> 5.1'
gem 'activemodel', '~> 5.1'


group :test do
  gem 'benchmark-ips'
  gem 'rspec', '~> 3.7'
end

group :development, :testing do
  gem 'yard'
  gem 'rspec_junit_formatter', git: 'https://github.com/p-mongo/rspec_junit_formatter', branch: 'mongodb'
  platforms :mri do
    gem 'byebug'
  end
end
