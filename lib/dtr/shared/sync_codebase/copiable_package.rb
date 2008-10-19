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
    class CopiablePackage
      include DRbUndumped
      include Package

      CHUNK_SIZE = 1024*1024

      def initialize
        raise "Package(#{codebase_package}) doesn't exist!" unless File.exist?(codebase_package)
      end

      def copy_into(remote_io)
        File.open(codebase_package, "rb") do |f|
          while (chunk = f.read(CHUNK_SIZE) || '') && chunk.length > 0
            remote_io.write(chunk)
          end
        end
      end

      def codebase_package
        File.join(package_dir, package_file)
      end
    end
  end
end
