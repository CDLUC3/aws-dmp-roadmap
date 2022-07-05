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
    system! "bin/rails db:create RAILS_ENV=#{ENV['RAILS_ENV']}"
    system! "bin/rails db:schema:load RAILS_ENV=#{ENV['RAILS_ENV']}"
    system! "bin/rails db:seed RAILS_ENV=#{ENV['RAILS_ENV']}"
  end

  system! "bin/rails db:migrate RAILS_ENV=#{ENV['RAILS_ENV']}"

  # system! "bin/rails assets:clobber RAILS_ENV=#{ENV['RAILS_ENV']}"
  # system! "bin/rails assets:precompile RAILS_ENV=#{ENV['RAILS_ENV']}"

  system! "bin/puma -C config/puma.rb -p 80"
end
