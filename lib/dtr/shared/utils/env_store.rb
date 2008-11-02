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

require 'pstore'

module DTR
  class EnvStore
    FILE_NAME = '.dtr_env_pstore' unless defined?(FILE_NAME)

    def self.default_file
      File.join(DTR.root || Dir.pwd, FILE_NAME)
    end

    def initialize(file=EnvStore.default_file)
      @pstore = PStore.new(File.expand_path(file))
    end

    def destroy
      File.delete(@pstore.path) if File.exist?(@pstore.path)
    end

    def [](key)
      @pstore.transaction(true) do
        @pstore[key]
      end
    end

    def []=(key, value)
      @pstore.transaction do
        @pstore[key] = value
      end
    end
    
    def <<(key_value)
      key, value = key_value
      array_value = (self[key] || []) << value
      self[key] = array_value
    end
  end

end
