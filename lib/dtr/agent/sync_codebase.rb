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

      def self.included(base)
        base.alias_method_chain :setup_env, :sync_codebase
        base.alias_method_chain :working_dir, :sync_codebase
      end

      def setup_env_with_sync_codebase(setup_env_cmd)
        unless same_working_dir_with_master_process?
          Dir.chdir(working_dir_without_sync_codebase) do
            sync_codebase
          end
        end
        setup_env_without_sync_codebase(setup_env_cmd)
      end

      def working_dir_with_sync_codebase
        same_working_dir_with_master_process? ? Dir.pwd : File.join(working_dir_without_sync_codebase, package_name)
      end

      private
      def same_working_dir_with_master_process?
        self[:host] == Socket.gethostname && self[:pwd] == Dir.pwd
      end
    end
  end
end
