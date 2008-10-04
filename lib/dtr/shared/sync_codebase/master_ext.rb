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
    module MasterExt
      include Service::File

      def self.included(base)
        base.alias_method_chain :with_dtr_master, :sync_codebase
        WorkingEnv.send(:include, WorkingEnvExt)
      end

      def with_dtr_master_with_sync_codebase(&block)
        with_dtr_master_without_sync_codebase do
          begin
            raise 'No dtr_package task defined in your rake tasks' unless Cmd.execute('rake dtr_repackage')

            provide_file Codebase.new
            block.call
          ensure
            Cmd.execute('rake dtr_clobber_package')
          end
        end
      end
    end
  end
end