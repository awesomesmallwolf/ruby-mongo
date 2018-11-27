source 'https://rubygems.org'
gemspec

gem 'rake'
gem 'actionpack', '~> 5.1'
gem 'activemodel', '~> 5.1'

# https://jira.mongodb.org/browse/MONGOID-4614
gem 'i18n', '~> 1.0', '>= 1.1'

group :test do
  gem 'rspec-retry'
  gem 'benchmark-ips'
  gem 'rspec', '~> 3.7'
  gem 'fuubar'
  gem 'rfc'
  platforms :mri do
    gem 'timeout-interrupt'
  end
end

group :development, :testing do
  gem 'yard'
  platforms :mri do
    gem 'byebug'
  end
end
