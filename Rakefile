# Rakefile for DTR        -*- ruby -*-

# Copyright 2007 by Li Xiao (swing1979@gmail.com)
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
task :tf => [:start_dtr_server, :start_dtr_runners, :test_functionals, :stop_dtr_runners, :stop_dtr_server]
task :test => :test_units

Rake::TestTask.new(:test_units) do |t|
  t.test_files = FileList['test/*test.rb']
  t.warning = true
  t.verbose = false
end

Rake::TestTask.new(:test_functionals) do |t|
  t.test_files = FileList['test/scenario*.rb']
  t.warning = true
  t.verbose = false
end

task :start_dtr_server do
  ruby "-I#{File.dirname(__FILE__) + "/lib"} #{File.dirname(__FILE__) + "/bin/dtr"} -s -D"
end

task :start_dtr_runners do
  ruby "-I#{File.dirname(__FILE__) + "/lib"} #{File.dirname(__FILE__) + "/bin/dtr"} -r r1,r2,r3 -D"
end

task :stop_dtr_runners do
  ruby "-I#{File.dirname(__FILE__) + "/lib"} #{File.dirname(__FILE__) + "/bin/dtr"} -R"
end

task :stop_dtr_server do
  ruby "-I#{File.dirname(__FILE__) + "/lib"} #{File.dirname(__FILE__) + "/bin/dtr"} -S"
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

PKG_FILES = FileList[
  'install.rb',
  '[A-Z]*',
  'bin/**/*', 
  'lib/**/*.rb', 
  'lib/**/*.rake', 
  'test/**/*.rb',
  'doc/**/*'
]
PKG_FILES.exclude('doc/example/*.o')
PKG_FILES.exclude(%r{doc/example/main$})

if ! defined?(Gem)
  puts "Package Target requires RubyGEMs"
else
  spec = Gem::Specification.new do |s|
    
    #### Basic information.

    s.name = 'dtr'
    s.version = $package_version
    s.summary = "DTR is a distributed test runner to run tests on distributed computers for decreasing build time."

    #### Dependencies and requirements.

    s.add_dependency('daemons', '> 1.0.7')
    #s.requirements << ""

    #### Which files are to be included in this gem?  Everything!  (Except SVN directories.)

    s.files = PKG_FILES.to_a.delete_if {|item| item.include?(".svn")}

    #### Load-time details: library and application (you will need one or both).

    s.require_path = 'lib'                         # Use these for libraries.

    s.bindir = "bin"                               # Use these for applications.
    s.executables = ["dtr"]
    s.default_executable = "dtr"

    #### Documentation and testing.

    s.has_rdoc = true
    s.extra_rdoc_files = rd.rdoc_files.reject { |fn| fn =~ /\.rb$/ }.to_a
    s.rdoc_options = rd.options

    #### Author and project details.

    s.author = "Li Xiao"
    s.email = "swing1979@gmail.com"
    s.homepage = "http://dtr.rubyforge.org"
    s.rubyforge_project = "dtr"
#     if ENV['CERT_DIR']
#       s.signing_key = File.join(ENV['CERT_DIR'], 'gem-private_key.pem')
#       s.cert_chain  = [File.join(ENV['CERT_DIR'], 'gem-public_cert.pem')]
#     end
  end

  package_task = Rake::GemPackageTask.new(spec) do |pkg|
    #pkg.need_zip = true
    #pkg.need_tar = true
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

# Define an optional publish target in an external file.  If the
# publish.rf file is not found, the publish targets won't be defined.

load "publish.rf" if File.exist? "publish.rf"

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

task :noop

desc "[rel, reuse, reltest] Make a new release"
task :release => [
  :prerelease,
  :clobber,
  :test_all,
  :update_version,
  :package,
  :tag] do
  
  announce 
  announce "**************************************************************"
  announce "* Release #{$package_version} Complete."
  announce "* Packages ready to upload."
  announce "**************************************************************"
  announce 
end

# Validate that everything is ready to go for a release.
desc "[rel, reuse, reltest]"
task :prerelease do |t, rel, reuse, reltest|
  $package_version = rel
  announce 
  announce "**************************************************************"
  announce "* Making RubyGem Release #{$package_version}"
  announce "* (current version #{CURRENT_VERSION})"
  announce "**************************************************************"
  announce  

  # Is a release number supplied?
  unless rel
    fail "Usage: rake release[X.Y.Z] [REUSE=tag_suffix]"
  end

  # Is the release different than the current release.
  # (or is REUSE set?)
  if $package_version == CURRENT_VERSION && ! reuse
    fail "Current version is #{$package_version}, must specify REUSE=tag_suffix to reuse version"
  end

  # Are all source files checked in?
  if reltest
    announce "Release Task Testing, skipping checked-in file test"
  else
    announce "Checking for unchecked-in files..."
    data = `svn st`
    unless data =~ /^$/
      abort "svn status is not clean ... do you have unchecked-in files?"
    end
    announce "No outstanding checkins found ... OK"
  end
end

desc "[rel, reuse, reltest]"
task :update_version => [:prerelease] do |t, rel, reuse, reltest|
  if rel == CURRENT_VERSION
    announce "No version change ... skipping version update"
  else
    announce "Updating DTR version to #{rel}"
    open("lib/dtr.rb") do |dtrin|
      open("lib/dtr.rb.new", "w") do |dtrout|
        dtrin.each do |line|
          if line =~ /^DTRVERSION\s*=\s*/
            dtrout.puts "DTRVERSION = '#{rel}'"
          else
            dtrout.puts line
          end
        end
      end
    end
    mv "lib/dtr.rb.new", "lib/dtr.rb"
    if reltest
      announce "Release Task Testing, skipping commiting of new version"
    else
      sh %{svn commit -m "Updated to version #{rel}" lib/dtr.rb} # "
    end
  end
end

desc "[rel, reuse, reltest] Tag all the CVS files with the latest release number (REL=x.y.z)"
task :tag => [:prerelease] do |t, rel, reuse, reltest|
  reltag = "REL_#{rel.gsub(/\./, '_')}"
  reltag << reuse.gsub(/\./, '_') if reuse
  announce "Tagging Repository with [#{reltag}]"
  if reltest
    announce "Release Task Testing, skipping CVS tagging"
  else
    sh %{svn copy svn+ssh://rubyforge.org/var/svn/dtr/trunk svn+ssh://rubyforge.org/var/svn/dtr/tags/#{reltag} -m 'Commiting release #{reltag}'}
  end
end

desc "Install the jamis RDoc template"
task :install_jamis_template do
  require 'rbconfig'
  dest_dir = File.join(Config::CONFIG['rubylibdir'], "rdoc/generators/template/html")
  fail "Unabled to write to #{dest_dir}" unless File.writable?(dest_dir)
  install "doc/jamis.rb", dest_dir, :verbose => true
end

task :c1 do
  Dir.chdir('testdata') do
    DTR.launch_runners(['c1'], nil)
  end
end

task :c3 do
  Dir.chdir('testdata') do
    DTR.launch_runners(['c1', 'c2', 'c3'], nil)
  end
end
task :c10 do
  Dir.chdir('testdata') do
    DTR.launch_runners(['c1', 'c2', 'c3', 'c4', 'c5', 'c6', 'c7', 'c8', 'c9', 'c10'], nil)
  end
end

task :runners do
  runners = DTR.runners
  if runners.empty?
    puts "No runner available!"
  else
    puts runners.collect{|r| r.name}.join(", ")
  end
end

task :c2 do
  DTROPTIONS[:names] = ['c1', 'c2']
  DTROPTIONS[:setup] = nil
  Dir.chdir('testdata') do
    DTR.start_runners
  end
end

task :server do
  DTR.start_server
end

Rake::TestTask.new(:dtr) do |t|
  t.libs << DTR.lib_path
  t.test_files = FileList['dtr/inject_with_svn.rb', 'testdata/*.rb']
  t.warning = true
  t.verbose = false
end

require 'dtr/raketasks'

DTR::MPTask.new :mt do |t|
  t.test_files = FileList['testdata/*.rb']
  t.processes = 2
end

