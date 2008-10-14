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
      launch_agent(DTR_AGENT_OPTIONS[:runners], DTR_AGENT_OPTIONS[:agent_env_setup_cmd])
    end

    def launch_agent(names, setup=nil)
      require 'dtr/agent'
      names = names || "DTR(#{Time.now})"
      DTR::Agent.start(names, setup)
    end

    def lib_path
      File.expand_path(File.dirname(__FILE__) + '/../')
    end

    def broadcast_list=(list)
      require 'dtr/shared'
      DTR.configuration.broadcast_list = list
      DTR.configuration.save
    end

    def agent_listen_port=(port)
      require 'dtr/shared'
      DTR.configuration.agent_listen_port = port
      DTR.configuration.save
    end

    def monitor
      require 'dtr/monitor'
      DTR.logger('dtr_monitor.log')
      Monitor.new.start
    end

    # For safe fork & kill sub process, should use Process.kill and Process.fork
    # At least have problem on ruby 1.8.6 114 with Kernel#kill & fork
    def kill_process(pid)
      Process.kill 'TERM', pid rescue nil
    end

    def fork_process(&block)
      Process.fork(&block)
    end
  end
end