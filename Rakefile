# Rakefile for DTR        -*- ruby -*-

# Copyright 2007 by Li Xiao (iam@li-xiao.com)
# All rights reserved.

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/lib')
require 'dtr'

require 'rake/clean'
require 'rake/testtask'
require 'rake/rdoctask'

begin
  require 'rubygems'
  require 'rake/gempackagetask'
rescue Exception
  nil
end
CLEAN.include('**/*.o', '*.dot')
CLOBBER.include('TAGS')
CLOBBER.include('coverage', 'rcov_aggregate')

def announce(msg='')
  STDERR.puts msg
end

if `ruby -Ilib ./bin/dtr --version` =~ /dtr, version ([0-9.]+)$/
  CURRENT_VERSION = $1
else
  CURRENT_VERSION = "0.0.0"
end

$package_version = CURRENT_VERSION

SRC_RB = FileList['lib/**/*.rb', 'lib/**/*.rake']

# The default task is run if rake is given no explicit arguments.

desc "Default Task"
task :default => :test_all

# Test Tasks ---------------------------------------------------------
task :dbg do |t|
  puts "Arguments are: #{t.args.join(', ')}"
end

# Common Abbreviations ...

task :test_all => [:test_units, :tf]
task :tu => :test_units
task :tf => [:test_functionals]
task :test => :test_units

Rake::TestTask.new(:test_units) do |t|
  t.test_files = FileList['test/unit/*_test.rb']
  t.warning = true
  t.verbose = false
end

Rake::TestTask.new(:test_functionals) do |t|
  t.test_files = FileList['test/acceptance/*_test.rb']
  t.warning = false
  t.verbose = false
end

directory 'testdata'
[:test_units].each do |t|
  task t => ['testdata']
end

# CVS Tasks ----------------------------------------------------------

# Install DTR using the standard install.rb script.

desc "Install the application"
task :install do
  ruby "setup.rb"
end

# Create a task to build the RDOC documentation tree.

rd = Rake::RDocTask.new("rdoc") { |rdoc|
  rdoc.rdoc_dir = 'html'
  rdoc.template = 'html'
  rdoc.title    = "DTR -- Distributed Test Runner"
  rdoc.options << '--line-numbers' << '--inline-source' <<
    '--main' << 'README' <<
    '--title' <<  '"DTR -- Distributed Test Runner' 
  rdoc.rdoc_files.include('README', 'LICENSE.txt', 'TODO', 'CHANGES')
  rdoc.rdoc_files.include('lib/**/*.rb')
}

# ====================================================================
# Create a task that will package the DTR software into distributable
# tar, zip and gem files.

if ! defined?(Gem)
  puts "Package Target requires RubyGEMs"
else
  Dir.glob(File.dirname(__FILE__) + "/testdata/**/log").each do |log_dir|
    FileUtils.rm_rf(log_dir)
  end

  gem_content = <<-GEM
Gem::Specification.new do |spec|
  spec.name = 'dtr'
  spec.version = "1.0.0"
  spec.summary = "DTR is a distributed test runner to run tests on distributed computers for decreasing build time."

  #### Dependencies and requirements.

  spec.files = #{(Dir.glob("lib/**/*.rb") + ["bin/dtr", "CHANGES", "dtr.gemspec", "install.rb", "lib", "LICENSE.TXT", "Rakefile", "README", "TODO"]).inspect}

  spec.test_files = #{(Dir.glob("test/**/*.rb") + Dir.glob("testdata/**/*")).inspect}
  #### Load-time details: library and application (you will need one or both).

  spec.require_path = 'lib'                         # Use these for libraries.

  spec.bindir = "bin"                               # Use these for applications.
  spec.executables = ["dtr"]
  spec.default_executable = "dtr"

  #### Documentation and testing.

  spec.has_rdoc = true
  spec.extra_rdoc_files = #{rd.rdoc_files.reject { |fn| fn =~ /\.rb$/ }.to_a.inspect}
  spec.rdoc_options = #{rd.options.inspect}

  #### Author and project details.

  spec.author = "Li Xiao"
  spec.email = "iam@li-xiao.com"
  spec.homepage = "http://github.com/xli/dtr/tree/master"
  spec.rubyforge_project = "dtr"
end
GEM
  File.open(File.dirname(__FILE__) + '/dtr.gemspec', 'w') do |f|
    f.write(gem_content)
  end

  #build gem package same steps with github
  File.open(File.dirname(__FILE__) + '/dtr.gemspec') do |f|
    data = f.read
    spec = nil
    Thread.new { spec = eval("$SAFE = 3\n#{data}") }.join
    package_task = Rake::GemPackageTask.new(spec) do |pkg|
      #pkg.need_zip = true
      #pkg.need_tar = true
    end
  end
end

# Misc tasks =========================================================

def count_lines(filename)
  lines = 0
  codelines = 0
  open(filename) { |f|
    f.each do |line|
      lines += 1
      next if line =~ /^\s*$/
      next if line =~ /^\s*#/
      codelines += 1
    end
  }
  [lines, codelines]
end

def show_line(msg, lines, loc)
  printf "%6s %6s   %s\n", lines.to_s, loc.to_s, msg
end

desc "Count lines in the main DTR file"
task :lines do
  total_lines = 0
  total_code = 0
  show_line("File Name", "LINES", "LOC")
  SRC_RB.each do |fn|
    lines, codelines = count_lines(fn)
    show_line(fn, lines, codelines)
    total_lines += lines
    total_code  += codelines
  end
  show_line("TOTAL", total_lines, total_code)
end

# Support Tasks ------------------------------------------------------

RUBY_FILES = FileList['**/*.rb'].exclude('pkg')

desc "Look for TODO and FIXME tags in the code"
task :todo do
  RUBY_FILES.egrep(/#.*(FIXME|TODO|TBD)/)
end

desc "Look for Debugging print lines"
task :dbg do
  RUBY_FILES.egrep(/\bDBG|\bbreakpoint\b/)
end

desc "List all ruby files"
task :rubyfiles do 
  puts RUBY_FILES
  puts FileList['bin/*'].exclude('bin/*.rb')
end
task :rf => :rubyfiles

desc "Create a TAGS file"
task :tags => "TAGS"

TAGS = 'xctags -e'

file "TAGS" => RUBY_FILES do
  puts "Makings TAGS"
  sh "#{TAGS} #{RUBY_FILES}", :verbose => false
end

task :update_site do
  puts %x[scp -r html/* lixiao@rubyforge.org:/var/www/gforge-projects/dtr/]
end

Rake::TestTask.new(:dtr_injected) do |t|
  t.libs.unshift DTR.lib_path
  t.test_files = FileList['dtr/test_unit_injection.rb', 'testdata/*.rb']
  t.warning = true
  t.verbose = false
end

require 'dtr/raketasks'

DTR::TestTask.new do |t|
  t.test_files = FileList['testdata/*.rb']
  t.processes = 0
  t.package_files.include('**/*')
end
