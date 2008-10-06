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
    module SyncService
      include Package
      include Service::File
      def sync_codebase
        DTR.info("start sync codebase, clean #{File.join(Dir.pwd, package_name)}")
        FileUtils.rm_rf(File.join(Dir.pwd, package_name))

        DTR.info("lookup codebase file")
        codebase = lookup_file
        DTR.info("receiving codebase: #{package_copy_file}")
        File.open(package_copy_file, 'w') do |f|
          codebase.write(f)
        end
        unless File.exists?(package_copy_file)
          raise "#{package_copy_file} does not exist, sync codebase failed."
        end
        unless Cmd.execute("tar -xjf #{package_copy_file}")
          raise "Extracting #{package_copy_file} by 'tar' failed."
        end
        DTR.info("sync codebase finished, clean #{package_copy_file}")
        FileUtils.rm_f(package_copy_file)
      end
    end
  end
end
