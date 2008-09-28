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
require 'rake/testtask'

module DTR
  class MPTask < Rake::TestTask
    attr_accessor :processes, :runner_options
    
    def define
      @libs.unshift DTR.lib_path
      lib_path = @libs.join(File::PATH_SEPARATOR)

      desc "Run tests" + (@name==:test ? "" : " for #{@name}")
      task @name do
        start_agent
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
          DTR.stop_agent_daemon_mode rescue nil
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
      %x[dtr -r #{runner_names.join(',')} -D #{runner_options}]
    end
  end
end
