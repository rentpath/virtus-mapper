require "bundler/gem_tasks"

begin # don't puke if rspec isn't available
  require 'rspec/core/rake_task'

  desc 'Run specs'
  RSpec::Core::RakeTask.new(:spec) do |r|
    r.verbose = false
    r.rspec_opts = '-t ~integration'
  end

rescue LoadError
end


