require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "luck"
    gem.summary = %Q{Pure-ruby CLI UI system}
    gem.description = %Q{Pure-ruby CLI UI system. Includes multiple panes in a display and multiple controls in a pane. luck is lucky (as opposed to ncurses being cursed)}
    gem.email = "me.github@danopia.net"
    gem.homepage = "http://github.com/danopia/luck"
    gem.authors = ["Daniel Danopia"]
    gem.add_development_dependency "thoughtbot-shoulda", ">= 0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

#~ require 'rake/testtask'
#~ Rake::TestTask.new(:test) do |test|
  #~ test.libs << 'lib' << 'test'
  #~ test.pattern = 'test/**/*_test.rb'
  #~ test.verbose = true
#~ end

#~ begin
  #~ require 'rcov/rcovtask'
  #~ Rcov::RcovTask.new do |test|
    #~ test.libs << 'test'
    #~ test.pattern = 'test/**/*_test.rb'
    #~ test.verbose = true
  #~ end
#~ rescue LoadError
  #~ task :rcov do
    #~ abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  #~ end
#~ end

task :test => :check_dependencies

task :default => :test

begin
  require 'yard'
  require 'yard/rake/yardoc_task'
  YARD::Rake::YardocTask.new do |t|
    extra_files = %w(LICENSE)
    t.files = ['lib/**/*.rb']
    t.options = ["--files=#{extra_files.join(',')}"]
  end
rescue LoadError
  task :yard do
    abort "YARD is not available. In order to run yard, you must: sudo gem install yard"
  end
end
