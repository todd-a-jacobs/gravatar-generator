begin
  require "rspec/core/rake_task"

  desc 'Run RSpec tests in standard mode'
  RSpec::Core::RakeTask.new
  
  desc 'Run RSpec tests in fancy mode'
  RSpec::Core::RakeTask.new(:fancy) do |t|
    t.rspec_opts = ["--color", "--format=doc"]
  end

  task :default => :fancy
rescue LoadError
  $stderr.puts 'RSpec ~> 2.0 needed for testing.'
  $stderr.puts
end

desc 'Generate readme file from internal documentation'
task :readme do
  File.open('README.rdoc', 'w+') do |file|
    file.puts IO.read('gravgen.rb').match(
      /^# == .*?(?=\n\n)/m
    ).to_s.gsub(/^# ?/, '')
  end
end

require 'rake/rdoctask.rb'
Rake::RDocTask.new do |rd|
  rd.rdoc_dir = 'rdoc'
  rd.rdoc_files.include '*.rb'
end
