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
  module SyncCodebase
    module WorkingEnvExt
      include SyncService

      def setup(runners)
        Dir.chdir(base_dir) do
          sync_codebase do
            runners.each do |runner_name|
              dir = File.expand_path escape_dir(runner_name)
              do_work(unpackage_cmd(dir))
            end
          end
        end
      end

      private
      # def same_working_dir_with_master_process?
      #   @working_env[:host] == Socket.gethostname && @working_env[:pwd] == Dir.pwd
      # end
    end
  end
end
