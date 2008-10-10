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

require 'test/unit/testresult'

module DTR
  module SyncCodebase
    module MasterExt
      include Service::File

      def self.included(base)
        base.alias_method_chain :with_dtr_master, :sync_codebase
      end

      def with_dtr_master_with_sync_codebase(&block)
        with_dtr_master_without_sync_codebase do
          DTR.do_println("Packaging codebase")
          unless Cmd.execute('rake dtr_repackage --trace')
            $stderr.puts %{
Execute dtr_repackage rake task failed, see log for details.
For running DTR test task, you must define a DTR::PackageTask task in your rakefile for DTR need package and synchronize your codebase within grid.
Example:
  require 'dtr/raketasks'
  DTR::PackageTask.new do |p|
    p.package_files.include("**/*")
    p.package_files.exclude("tmp")
    p.package_files.exclude("log")
  end
}
            return Test::Unit::TestResult.new
          end
          begin
            provide_file Codebase.new
            block.call
          ensure
            Cmd.execute('rake dtr_clobber_package --trace')
          end
        end
      end
    end
  end
end
