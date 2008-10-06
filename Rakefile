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

begin
  require 'rcov/rcovtask'

  Rcov::RcovTask.new do |t|
    t.libs << "test"
    t.rcov_opts = [
      '-xRakefile', '-xrakefile', '-xpublish.rf', '--text-report',
    ]
    t.test_files = FileList[
      'test/*test.rb'
    ]
    t.output_dir = 'coverage'
    t.verbose = true
  end
rescue LoadError
  # No rcov available
end

directory 'testdata'
[:test_units].each do |t|
  task t => ['testdata']
end

# CVS Tasks ----------------------------------------------------------

# Install DTR using the standard install.rb script.

desc "Install the application"
task :install do
  ruby "install.rb"
end

# Create a task to build the RDOC documentation tree.

rd = Rake::RDocTask.new("rdoc") { |rdoc|
  rdoc.rdoc_dir = 'html'
#  rdoc.template = 'kilmer'
#  rdoc.template = 'css2'
  rdoc.template = 'doc/jamis.rb'
  rdoc.title    = "DTR -- Distributed Test Runner"
  rdoc.options << '--line-numbers' << '--inline-source' <<
    '--main' << 'README' <<
    '--title' <<  '"DTR -- Distributed Test Runner' 
  rdoc.rdoc_files.include('README', 'LICENSE.txt', 'TODO', 'CHANGES')
  rdoc.rdoc_files.include('lib/**/*.rb', 'doc/**/*.rdoc')
}

# ====================================================================
# Create a task that will package the DTR software into distributable
# tar, zip and gem files.

if ! defined?(Gem)
  puts "Package Target requires RubyGEMs"
else
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

# --------------------------------------------------------------------
# Creating a release

task :update_site do
  puts %x[scp -r html/* lixiao@rubyforge.org:/var/www/gforge-projects/dtr/]
end

task :c1 do
  DTR.launch_agent(['c1'], nil)
end

task :c3 do
  DTR.launch_agent(['c1', 'c2', 'c3'], nil)
end
task :c10 do
  DTR.launch_agent(['c1', 'c2', 'c3', 'c4', 'c5', 'c6', 'c7', 'c8', 'c9', 'c10'], nil)
end

task :c2 do
  DTR_AGENT_OPTIONS[:runners] = ['c1', 'c2']
  DTR_AGENT_OPTIONS[:agent_env_setup_cmd] = nil
  Dir.chdir('testdata') do
    DTR.start_agent
  end
end

Rake::TestTask.new(:dtr) do |t|
  t.libs.unshift DTR.lib_path
  t.test_files = FileList['dtr/test_unit_injection.rb', 'testdata/*.rb']
  t.warning = true
  t.verbose = false
end

require 'dtr/raketasks'

DTR::TestTask.new :mt do |t|
  t.test_files = FileList['testdata/*.rb']
  t.processes = 2
end
# 
# DTR::PackageTask.new do |p|
#   p.package_files.include("**/*")
#   p.package_files.exclude("tmp")
#   p.package_files.exclude("log")
# end
# 

