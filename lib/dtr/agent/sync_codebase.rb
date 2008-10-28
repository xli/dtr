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
            FileUtils.rm_rf(package_name)
            do_work(unpackage_cmd)
            runners.each do |runner_name|
              dir = File.expand_path escape_dir(runner_name)
              FileUtils.rm_rf(dir)
              FileUtils.cp_r(package_name, dir)
            end
          end
        end
      end
    end
  end
end
