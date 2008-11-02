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
  module Facade
    def start_agent
      require 'dtr/agent'
      DTR::Agent.start
    end

    def lib_path
      File.expand_path(File.dirname(__FILE__) + '/../')
    end

    def broadcast_list=(list)
      DTR.configuration.broadcast_list = list
      DTR.configuration.save
    end

    def agent_listen_port=(port)
      DTR.configuration.agent_listen_port = port
      DTR.configuration.save
    end

    def group=(group)
      DTR.configuration.group = group
      DTR.configuration.save
    end

    def agent_env_setup_cmd=(cmd)
      DTR.configuration.agent_env_setup_cmd = cmd
      DTR.configuration.save
    end

    def agent_runners=(runners)
      DTR.configuration.agent_runners = runners
      DTR.configuration.save
    end

    def agent_runners
      DTR.configuration.agent_runners
    end

    def monitor
      require 'dtr/monitor'
      DTR.logger('dtr_monitor.log')
      Monitor.new.start
    end

    DTR_CMD = File.expand_path(File.dirname(__FILE__) + '/../../bin/dtr')
    def run_script(cmd)
      system "#{DTR_CMD} -e #{cmd.inspect}"
    end
  end
end