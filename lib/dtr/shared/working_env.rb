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
  class WorkingEnv
    def initialize
      files = (defined?($argv_dup) ? $argv_dup : []).dup
      @env = {:libs => $LOAD_PATH.dup, :files => files, :created_at => Time.now.to_s, :dtr_master_env => ENV['DTR_MASTER_ENV'], :agent_env_setup_cmd => ENV['DTR_AGENT_ENV_SETUP_CMD'], :identifier => "#{Time.now.to_s}:#{rand}:#{object_id}", :host => Socket.gethostname, :pwd => Dir.pwd}
    end

    def [](key)
      @env[key]
    end
    
    def []=(key, value)
      @env[key] = value
    end
    
    def to_s
      @env.inspect
    end
    
    def ==(obj)
      obj && obj[:identifier] == self[:identifier]
    end
  end
end
