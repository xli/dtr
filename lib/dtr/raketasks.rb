# Copyright (c) 2007-2008 Li Xiao <iam@li-xiao.com>
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "rubygems"
require 'rake'
require 'rake/testtask'
require 'rake/tasklib'

require 'dtr'
require 'dtr/shared/ruby_ext'
require 'dtr/shared/utils'
require 'dtr/shared/sync_codebase/package'

module DTR
  # Create tasks that run a set of tests with DTR injected.
  # The TestTask will create the following targets:
  #
  # [<b>:dtr</b>]: 
  #   Create a task that runs a set of tests by DTR master.
  #
  # [DTR::PackageTask]: 
  #   Create a packaging task that will package the project into
  #   distributable files for running test on remote machine.
  #   All test files should be included.
  #
  # Example:
  #   require 'dtr/raketasks'
  #
  #   DTR::TestTask.new do |t|
  #     t.libs << "test"
  #     t.test_files = FileList['test/test*.rb']
  #     t.verbose = true
  #     t.processes = 1 # default is 1
  #     t.package_files.include("lib/**/*") # default is FileList["**/*"]
  #     t.package_files.include("test/**/*")
  #   end
  #
  # This task inherits from Rake::TestTask, and adds 2 DTR specific 
  # options: processes and package_files.
  #
  class TestTask < Rake::TestTask

    #
    # The option processes is used to start an DTR agent in same directory
    # with master process. The number of processes is the size of runners
    # launched by agent for running tests. If processes is set to 0, 
    # then there is no agent started locally.
    # Default is 1.
    attr_accessor :processes

    # List of files to be included in the package for running tests on
    # remote agent.
    # The agent, which starts in same directory on same machine with 
    # master process, would skip copying codebase.
    # The default package files is Rake::FileList["**/*"].
    attr_accessor :package_files

    def initialize(name=:dtr)
      @processes = 1
      @package_files = Rake::FileList.new
      super(name)
    end

    def define
      PackageTask.new do |p|
        p.package_files = package_files
        if p.package_files.empty?
          p.package_files.include("**/*")
        end
      end

      @libs.unshift DTR.lib_path
      lib_path = @libs.join(File::PATH_SEPARATOR)

      desc "Run tests with DTR injected"
      task @name do
        @agent = start_agent
        run_code = ''
        begin
          RakeFileUtils.verbose(@verbose) do
            run_code = rake_loader
            @ruby_opts.unshift( "-I#{lib_path}" )
            @ruby_opts.unshift( "-w" ) if @warning
            
            ruby @ruby_opts.join(" ") +
              " \"#{run_code}\" " +
              file_list.unshift('dtr/test_unit_injection.rb').collect { |fn| "\"#{fn}\"" }.join(' ') +
              " #{option_list}"
          end
        ensure
          if defined?(@agent)
            DTR.kill_process @agent
          end
        end
      end
      self
    end

    private
    def start_agent
      return if self.processes.to_i <= 0
      runner_names = []
      self.processes.to_i.times {|i| runner_names << "runner#{i}"}
      
      DTR.fork_process do
        DTR.agent_runners = runner_names if DTR.agent_runners.blank?
        DTR.start_agent
      end
    end
  end

  # Create a packaging task that will package the project into
  # distributable files for running test on remote machine.
  # It uses zip and unzip to package and unpackage files.
  # All test files should be included.
  #
  # The PackageTask will create the following targets:
  #
  # [<b>:dtr_package</b>]
  #   Create all the requested package files.
  #
  # [<b>:dtr_clobber_package</b>]
  #   Delete all the package files. This target is automatically
  #   added to the main clobber target.
  #
  # [<b>:dtr_repackage</b>]
  #   Rebuild the package files from scratch, even if they are not out
  #   of date.
  #
  # Example:
  #
  #   DTR::PackageTask.new do |p|
  #     p.package_files.include("lib/**/*.rb")
  #     p.package_files.include("test/**/*.rb")
  #   end
  #
  class PackageTask < Rake::TaskLib
    include SyncCodebase::Package
    # List of files to be included in the package.
    attr_accessor :package_files

    # Create a Package Task with the given name and version. 
    def initialize
      @package_files = Rake::FileList.new
      yield self if block_given?
      define
    end

    # Create the tasks defined by this task library.
    def define
      desc "Build packages for dtr task"
      task :dtr_package

      desc "Force a rebuild of the package files for dtr task"
      task :dtr_repackage => [:dtr_clobber_package, :dtr_package]

      desc "Remove package for dtr task" 
      task :dtr_clobber_package do
        rm_r package_dir rescue nil
      end

      file, flag = package_file, 'j'
      task :dtr_package => ["#{package_dir}/#{file}"]

      file "#{package_dir}/#{file}" => [package_dir_path] do
        chdir(package_dir) do
          do_work(package_cmd)
        end
      end

      directory package_dir

      file package_dir_path do
        mkdir_p package_dir rescue nil
        @package_files.exclude(package_dir)
        @package_files.each do |fn|
          f = File.join(package_dir_path, fn)
          fdir = File.dirname(f)
          mkdir_p(fdir) if !File.exist?(fdir)
          if File.directory?(fn)
            mkdir_p(f)
          else
            rm_f f
            safe_ln(fn, f)
          end
        end
      end
      self
    end
  end
end
