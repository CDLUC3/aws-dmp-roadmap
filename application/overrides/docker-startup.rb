#!/usr/bin/env ruby
require 'fileutils'
include FileUtils

# path to your application root.
APP_ROOT = File.expand_path('..', __dir__)

def system!(*args)
  system(*args) || abort("\n== Command #{args} failed ==")
end

chdir APP_ROOT do
  # This script is a starting point to setup your application.
  # Add necessary setup steps to this file.
  if ENV['DB_SNAPSHOT'] == 'none'
    system! "bundle exec rails db:create RAILS_ENV=#{ENV['RAILS_ENV']}"
    system! "bundle exec rails db:schema:load RAILS_ENV=#{ENV['RAILS_ENV']}"
    system! "bundle exec rails db:seed RAILS_ENV=#{ENV['RAILS_ENV']}"
  end

  system! "bundle exec rails db:migrate RAILS_ENV=#{ENV['RAILS_ENV']}"
  system! "bundle exec rails assets:precompile"

  system! "bundle exec puma -C config/application.rb -p 80 RAILS_ENV=#{ENV['RAILS_ENV']}"
end
