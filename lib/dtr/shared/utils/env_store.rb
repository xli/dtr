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

    def initialize
      @file = File.expand_path(File.join(DTR.root, FILE_NAME))
      @pstore = PStore.new(@file)
    end

    def destroy
      File.delete(@file) if File.exist?(@file)
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
      @pstore.transaction do
        @pstore[key] = (@pstore[key] || []) << value
      end
    end
    
    def shift(key)
      @pstore.transaction do
        if array = @pstore[key]
          array.shift
          @pstore[key] = array
        end
      end
    end
  end

end
