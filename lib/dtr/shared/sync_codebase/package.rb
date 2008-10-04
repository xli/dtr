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
    module Package
      def package_dir
        'dtr_pkg'
      end

      def package_name
        'codebase-dump'
      end

      def package_dir_path
        "#{package_dir}/#{package_name}"
      end

      def package_file
        "#{package_name}.tar.bz2"
      end

      def package_copy_file
        "copy_#{package_file}"
      end
    end
  end
end
