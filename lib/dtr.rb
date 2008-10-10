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

DTRVERSION="1.0.0"
DTR_AGENT_OPTIONS = {:runners => [], :agent_env_setup_cmd => nil}

module DTR

  def start_agent
    launch_agent(DTR_AGENT_OPTIONS[:runners], DTR_AGENT_OPTIONS[:agent_env_setup_cmd])
  end

  def launch_agent(names, setup=nil)
    require 'dtr/agent'
    names = names || "DTR(#{Time.now})"
    DTR::Agent.start(names, setup)
  end

  def lib_path
    File.expand_path(File.dirname(__FILE__))
  end

  def broadcast_list=(list)
    require 'dtr/shared'
    DTR.configuration.broadcast_list = list
    DTR.configuration.save
  end

  def port=(port)
    require 'dtr/shared'
    DTR.configuration.rinda_server_port = port
    DTR.configuration.save
  end

  def monitor
    require 'dtr/monitor'
    DTR.logger('dtr_monitor.log')
    Monitor.new.start
  end

  module_function :start_agent, :launch_agent, :lib_path, :broadcast_list=, :monitor, :port=
end
