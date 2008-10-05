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

module DTR
  module Agent
    module WorkingEnvExt
      def within
        ENV['DTR_MASTER_ENV'] = self[:dtr_master_env]
        Dir.chdir(working_dir) do
          yield
        end
      end

      def setup_env(setup_env_cmd)
        within do
          Cmd.execute(setup_env_cmd || self[:agent_env_setup_cmd])
        end
      end

      private
      def escape(str)
        str.gsub(/[^a-zA-Z0-9]/, '_')
      end

      def working_dir
        return @working_dir if defined?(@working_dir)
        project_name = self[:pwd].length > 20 ? self[:pwd][-20..-1] : self[:pwd]
        @working_dir = File.join(escape(self[:host]), escape(project_name))
        FileUtils.mkdir_p(@working_dir)
        @working_dir
      end
    end
  end
end
