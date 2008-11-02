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
          DTR.info "Loading environment at #{Dir.pwd}"

          ENV['DTR_MASTER_ENV'] = dtr_master_env

          setup_environment

          load_libs
          load_files

          block.call
        end
      end

      private

      def setup_environment_command
        DTR.configuration.agent_env_setup_cmd || self.agent_env_setup_cmd
      end

      def setup_environment
        unless Cmd.execute(setup_environment_command)
          raise "Stopped for setup working environment failed."
        end
      end

      def escape_dir(str)
        str.to_s.gsub(/[^a-zA-Z0-9]/, '_')
      end

      def load_libs
        libs.select{ |lib| !$LOAD_PATH.include?(lib) && File.exists?(lib) }.each do |lib|
          $LOAD_PATH << lib
          DTR.debug {"appended lib: #{lib}"}
        end
        DTR.info {"libs loaded"}
        DTR.debug {"$LOAD_PATH: #{$LOAD_PATH.inspect}"}
      end

      def load_files
        files.each do |f|
          begin
            load f unless f =~ /^-/
            DTR.debug {"loaded #{f}"}
          rescue LoadError => e
            DTR.error {"No such file to load -- #{f}"}
            DTR.debug {"Environment: #{self}"}
          end
        end
        DTR.info {"test files loaded"}
      end
    end
  end
end
