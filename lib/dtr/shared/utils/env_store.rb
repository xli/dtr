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

    def self.destroy
      File.delete(FILE_NAME) if File.exist?(FILE_NAME)
    end

    def [](key)
      return nil unless File.exist?(FILE_NAME)
      
      repository = PStore.new(FILE_NAME)
      repository.transaction(true) do
        repository[key]
      end
    end

    def []=(key, value)
      repository = PStore.new(FILE_NAME)
      repository.transaction do
        repository[key] = value
      end
    end
    
    def <<(key_value)
      key, value = key_value
      repository = PStore.new(FILE_NAME)
      repository.transaction do
        repository[key] = (repository[key] || []) << value
      end
    end
    
    def shift(key)
      repository = PStore.new(FILE_NAME)
      repository.transaction do
        if array = repository[key]
          array.shift
          repository[key] = array
        end
      end
    end
  end

end
