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
  module SyncCodebase
    module WorkingEnvExt
      include SyncService

      def self.included(base)
        base.alias_method_chain :setup_env, :sync_codebase
        base.alias_method_chain :working_dir, :sync_codebase
      end

      def setup_env_with_sync_codebase(setup_env_cmd)
        Dir.chdir(working_dir_without_sync_codebase) do
          sync_codebase
        end
        setup_env_without_sync_codebase(setup_env_cmd)
      end

      def working_dir_with_sync_codebase
        File.join(working_dir_without_sync_codebase, package_name)
      end
    end
  end
end
