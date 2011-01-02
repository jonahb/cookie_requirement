require 'rake'
require 'rake/testtask'

task :default => :test

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Build gem'
task :build do
  system "gem build cookie_requirement.gemspec"
end
