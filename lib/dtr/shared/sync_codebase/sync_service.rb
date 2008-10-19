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
    module SyncService
      include Package
      include Service::File
      def sync_codebase
        DTR.info("Start sync codebase, clean #{File.join(Dir.pwd, package_name)}")
        FileUtils.rm_rf(File.join(Dir.pwd, package_name))

        DTR.info("Lookup codebase package file")
        package = lookup_file
        DTR.info("Receiving package file and writing to #{package_copy_file}")
        File.open(package_copy_file, 'w') do |f|
          package.copy_into(f)
        end
        do_work(unpackage_cmd)
        DTR.info("sync codebase finished, clean #{package_copy_file}")
        FileUtils.rm_f(package_copy_file)
      end
    end
  end
end
