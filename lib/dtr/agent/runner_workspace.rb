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

module DTR
  module Agent
    class RunnerWorkspace
      def initialize(runner_name)
        @runner_name = runner_name
        @working_env = DTR.configuration.working_env
      end

      def setup(&block)
        log(:info, "Initialize runner workspace...")

        ENV['DTR_RUNNER_NAME'] = @runner_name
        ENV['DTR_MASTER_ENV'] = @working_env[:dtr_master_env]

        Dir.chdir(working_dir) do
          unless Cmd.execute(DTR.configuration.agent_env_setup_cmd || @working_env[:agent_env_setup_cmd])
            raise "Setup #{@runner_name} working environment failed."
          end

          load_libs
          load_files

          block.call
        end
      end

      def working_dir
        return @working_dir if defined?(@working_dir)
        project_specific_len = 20
        project_name = @working_env[:pwd].length > project_specific_len ? @working_env[:pwd][-project_specific_len..-1] : @working_env[:pwd]
        @working_dir = File.join(escape(@working_env[:host]), escape(project_name), escape(@runner_name))
        
        FileUtils.mkdir_p(@working_dir)
        @working_dir
      end

      private

      def load_libs
        @working_env[:libs].select{ |lib| !$LOAD_PATH.include?(lib) && File.exists?(lib) }.each do |lib|
          $LOAD_PATH << lib
          log(:debug, "appended lib: #{lib}")
        end
        log(:info, "libs loaded")
        log(:debug, "$LOAD_PATH: #{$LOAD_PATH.inspect}")
      end

      def load_files
        @working_env[:files].each do |f|
          begin
            load f unless f =~ /^-/
            log(:debug, "loaded #{f}")
          rescue LoadError => e
            log(:error, "No such file to load -- #{f}")
            log(:debug, "Environment: #{@working_env}")
          end
        end
        log(:info, "test files loaded")
      end

      def escape(str)
        str.to_s.gsub(/[^a-zA-Z0-9]/, '_')
      end

      def log(level, msg)
        DTR.send(level) { "#{@runner_name}: #{msg}" }
      end
    end
  end
end
