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
        base.alias_method_chain :within, :sync_codebase
      end

      def within_with_sync_codebase(&block)
        within_without_sync_codebase do
          working_dtr = File.join(Dir.pwd, package_name)
          unless File.exists?(working_dtr) #first time, need sync codebase first
            sync_codebase
            raise "#{package_copy_file} does not exist" unless File.exists?(package_copy_file)
            raise "extracting #{package_copy_file} failed" unless Cmd.execute("tar -xjf #{package_copy_file}")
          end

          DTR.info {"working dir: #{working_dtr}"}
          Dir.chdir(working_dtr) do
            block.call
          end
        end
      end
    end
  end
end
