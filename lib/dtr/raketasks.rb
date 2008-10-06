# Copyright (c) 2007-2008 Li Xiao
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
require 'dtr'
require 'dtr/shared/sync_codebase/package'
require 'rake'
require 'rake/testtask'
require 'rake/tasklib'

module DTR
  class TestTask < Rake::TestTask
    attr_accessor :processes
    
    def define
      @libs.unshift DTR.lib_path
      lib_path = @libs.join(File::PATH_SEPARATOR)

      desc "Run tests" + (@name==:test ? "" : " for #{@name}")
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
            Process.kill 'TERM', @agent rescue nil
          end
        end
      end
      self
    end
    
    def processes
      @processes ? @processes.to_i : 2
    end
    
    private
    def start_agent
      return if self.processes.to_i <= 0
      runner_names = []
      self.processes.to_i.times {|i| runner_names << "runner#{i}"}
      
      Process.fork do
        DTR_AGENT_OPTIONS[:runners] = runner_names unless DTR_AGENT_OPTIONS[:runners]
        DTR.start_agent
      end
    end
  end

  # The following task is copied & modified from 'rake/packagetask'
  class PackageTask < Rake::TaskLib
    include SyncCodebase::Package
    # List of files to be included in the package.
    attr_accessor :package_files

    # Tar command for gzipped or bzip2ed archives.  The default is 'tar'.
    attr_accessor :tar_command

    # Create a Package Task with the given name and version. 
    def initialize
      @package_files = Rake::FileList.new
      @tar_command = 'tar'
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
          sh %{#{@tar_command} #{flag}cvf #{file} #{package_name}}
        end
      end

      directory package_dir

      file package_dir_path do
        mkdir_p package_dir rescue nil
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
