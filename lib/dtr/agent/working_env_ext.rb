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
    module WorkingEnvExt
      def base_dir
        return @base_dir if defined?(@base_dir)
        project_specific_len = 20
        project_name = self[:pwd].length > project_specific_len ? self[:pwd][-project_specific_len..-1] : self[:pwd]
        @base_dir = File.expand_path FileUtils.mkdir_p(File.join(escape_dir(self[:host]), escape_dir(project_name)))
      end

      def load_environment(&block)
        working_dir = FileUtils.mkdir_p(File.join(base_dir, escape_dir(ENV['DTR_RUNNER_NAME'])))
        Dir.chdir(working_dir) do
          log(:info, "Loading environment at #{Dir.pwd}, pid: #{Process.pid}")

          ENV['DTR_MASTER_ENV'] = dtr_master_env

          unless Cmd.execute(DTR.configuration.agent_env_setup_cmd || self.agent_env_setup_cmd)
            raise "Stopped for setup working environment failed."
          end

          load_libs
          load_files

          block.call
        end
      end

      private

      def escape_dir(str)
        str.to_s.gsub(/[^a-zA-Z0-9]/, '_')
      end

      def load_libs
        libs.select{ |lib| !$LOAD_PATH.include?(lib) && File.exists?(lib) }.each do |lib|
          $LOAD_PATH << lib
          log(:debug, "appended lib: #{lib}")
        end
        log(:info, "libs loaded")
        log(:debug, "$LOAD_PATH: #{$LOAD_PATH.inspect}")
      end

      def load_files
        files.each do |f|
          begin
            load f unless f =~ /^-/
            log(:debug, "loaded #{f}")
          rescue LoadError => e
            log(:error, "No such file to load -- #{f}")
            log(:debug, "Environment: #{self}")
          end
        end
        log(:info, "test files loaded")
      end

      def log(level, msg)
        DTR.send(level) { "#{ENV['DTR_RUNNER_NAME']}: #{msg}" }
      end
    end
  end
end
