require "rake"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

RSpec::Core::RakeTask.new(:api) do |t|
  t.rspec_opts = '--pattern "api/*_spec.rb"'
end

task :default => :spec
