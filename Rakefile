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

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
    gem.name = "ap"
    gem.homepage = "http://github.com/drcapulet/ap"
    gem.license = "MIT"
    gem.summary = %Q{Ruby Associated Press API Gem}
    gem.description = %Q{Ruby gem for interfacing with the Associated Press Breaking News API}
    gem.email = "alex@alexcoomans.com"
    gem.authors = ["Alex Coomans"]
    gem.add_runtime_dependency 'httparty', '>=0.7.7'
    gem.add_development_dependency 'rspec', '>= 2.5.0'
    gem.add_development_dependency 'webmock', '>= 1.6.2'
    gem.add_development_dependency 'bundler', '~> 1.0.0'
    gem.add_development_dependency 'jeweler', '~> 1.5.2'
    gem.add_development_dependency 'rcov', '>= 0.9.9'
  end
  Jeweler::RubygemsDotOrgTasks.new
rescue LoadError
  puts "Jeweler isn't installed. You won't be able to run gem commands"
end


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