#!/bin/bash

set -o xtrace   # Write all commands first to stderr
set -o errexit  # Exit the script with error if any of the commands fail

# Supported/used environment variables:
#       MONGODB_URI             Set the suggested connection MONGODB_URI (including credentials and topology info)
#       RVM_RUBY                Define the Ruby version to test with, using its RVM identifier.
#                               For example: "ruby-2.3" or "jruby-9.1"

MONGODB_URI=${MONGODB_URI:-}

export CI=evergreen
export JRUBY_OPTS="--server -J-Xms512m -J-Xmx1G"

source ~/.rvm/scripts/rvm

# Don't errexit because this may call scripts which error
set +o errexit
rvm use $RVM_RUBY
set -o errexit

# Ensure we're using the right ruby
python - <<EOH
ruby = "${RVM_RUBY}".split("-")[0]
version = "${RVM_RUBY}".split("-")[1]
assert(ruby in "`ruby --version`")
assert(version in "`ruby --version`")
EOH

gem install bundler

if [ $DRIVER == "master" ]; then
  bundle install --gemfile=gemfiles/driver_master.gemfile
elif [ $RAILS == "master" ]; then
    bundle install --gemfile=gemfiles/rails_master.gemfile
else
  bundle install
fi

bundle exec rake spec
