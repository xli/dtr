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

require 'dtr/shared'
require 'dtr/agent/working_env_ext'
require 'dtr/agent/sync_codebase'
require 'dtr/agent/rails_ext'
require 'dtr/agent/working_status'

require 'dtr/agent/sync_logger'
require 'dtr/agent/process_root'
require 'dtr/agent/brain'
require 'dtr/agent/worker'
require 'dtr/agent/test_unit'
require 'dtr/agent/herald'
require 'dtr/agent/test_case'
require 'dtr/agent/runner'

DTR.logger('dtr_agent.log')

module DTR
  module Agent
    def start(action=:hypnotize)
      Brain.new.send(action)
    end
    
    module_function :start

    WorkingEnv.send(:include, WorkingEnvExt)
    WorkingEnv.send(:include, SyncCodebase::WorkingEnvExt)
    WorkingEnv.send(:include, RailsExt::WorkingEnvExt)
    Configuration.send(:include, WorkingStatus)
  end
end
