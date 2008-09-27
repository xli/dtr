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

require 'dtr/service_provider'
require 'dtr/decorator'

require 'dtr/agent/base'
require 'dtr/agent/service_provider'
require 'dtr/agent/test_unit'
require 'dtr/agent/heart'
require 'dtr/agent/herald'
require 'dtr/agent/runner'

module DTR
  module Agent
    def start(runner_names=["Distributed Test Runner"], agent_env_setup_cmd=nil)
      DTR.with_monitor do
        Base.new(runner_names, agent_env_setup_cmd).launch
      end
    end
    
    module_function :start
  end
end