require 'rubygems'
require 'bundler'

Bundler::GemHelper.install_tasks

task :default => :spec

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.rcov = true
end

require 'yard'
YARD::Rake::YardocTask.new

#
# ------------------------------ watirspec -----------------------------------
#

if File.exist?(path = "spec/watirspec/watirspec.rake")
  load path
end

namespace :watirspec do
  desc 'Initialize and fetch the watirspec submodule'
  task :init do
    sh "git submodule init"
    sh "git submodule update"
  end
end
