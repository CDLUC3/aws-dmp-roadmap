#!/usr/bin/env ruby

require 'fileutils'

include FileUtils

# path to your application root.
APP_ROOT = File.expand_path('..', __dir__)

def system!(*args)
  system(*args) || abort("\n== Command #{args} failed ==")
end

chdir "#{APP_ROOT}/roadmap" do
  prefix = "RAILS_ENV=#{ENV['RAILS_ENV']}"
  system! "bin/rails db:environment:set RAILS_ENV=#{ENV['RAILS_ENV']}"

  # If the default DBSnapshot is present, then rebuild the database from scratch
  if ENV['DB_SNAPSHOT'] == 'none'
    system! "#{prefix} bin/rails db:drop"
    system! "#{prefix} bin/rails db:create"
    system! "#{prefix} bin/rails db:schema:load"
    system! "#{prefix} bin/rails db:seed"
  end

  system! "export WICKED_PDF_PATH=`which wkhtmltopdf`"

  system! "#{prefix} bin/rails db:migrate"

  system! "#{prefix} bin/rails assets:precompile"

  system! "#{prefix} bin/puma -C config/puma.rb -p 80"
end
