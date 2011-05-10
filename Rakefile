require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

Bundler::GemHelper.install_tasks


begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)

  task :test => :spec
  task :default => :spec

  # require 'rcov/rcovtask'
  # Rcov::RcovTask.new do |test|
  #   test.libs << 'test'
  #   test.pattern = 'test/**/test_*.rb'
  #   test.verbose = true
  # end

  require 'rake/rdoctask'
  Rake::RDocTask.new do |rdoc|
    version = File.exist?('VERSION') ? File.read('VERSION') : ""

    rdoc.rdoc_dir = 'rdoc'
    rdoc.title = "ap #{version}"
    rdoc.rdoc_files.include('README*')
    rdoc.rdoc_files.include('lib/**/*.rb')
  end
rescue LoadError => e
  puts e
end