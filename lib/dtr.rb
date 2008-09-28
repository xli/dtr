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

DTRVERSION="0.0.5"
DTROPTIONS = {} unless defined?(DTROPTIONS)

require 'fileutils'

module DTR

  def start_agent
    launch_agent(DTROPTIONS[:names], DTROPTIONS[:setup])
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
    require 'dtr/service_provider'
    ServiceProvider.broadcast_list = list
  end
  
  def port=(port)
    require 'dtr/service_provider'
    ServiceProvider.port = port 
  end
  
  def monitor
    require 'dtr/service_provider'
    DTROPTIONS[:log_file] = 'dtr_monitor.log'
    ServiceProvider::Base.new.monitor
  end
  
  def stop_agent_daemon_mode
    with_daemon_gem do
      Daemons.run_proc "dtr_agent", :ARGV => ['stop'] 
    end
  end
  
  def start_agent_daemon_mode
    with_daemon_gem do
      FileUtils.rm_rf('dtr_agent.output')
      pwd = Dir.pwd
      Daemons.run_proc "dtr_agent", :ARGV => ['start'], :backtrace => true  do
        Dir.chdir(pwd) do
          start_agent
        end
      end
    end
  end
  
  def with_daemon_gem
    require "rubygems"
    begin
      require "daemons"
    rescue LoadError
      raise "The daemons gem must be installed"
    end
    yield
  end
  
  module_function :start_agent, :launch_agent, :lib_path, :broadcast_list=, :with_daemon_gem, :start_agent_daemon_mode, :stop_agent_daemon_mode, :monitor, :port=
end
