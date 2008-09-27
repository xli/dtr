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

  def start_server
    require 'dtr/service_provider'
    ServiceProvider::Base.new.start
  end
  
  def start_runners
    launch_runners(DTROPTIONS[:names], DTROPTIONS[:setup])
  end
  
  def launch_runners(names, setup=nil)
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
  
  def runners
    require 'dtr/service_provider'
    ServiceProvider::Base.new.all_working_runners
  end
  
  def monitor
    require 'dtr/service_provider'
    DTROPTIONS[:log_file] = 'dtr_monitor.log'
    ServiceProvider::Base.new.monitor
  end
  
  def stop_runners_daemon_mode
    with_daemon_gem do
      Daemons.run_proc "dtr_runners", :ARGV => ['stop'] 
    end
  end
  
  def start_runners_daemon_mode
    with_daemon_gem do
      FileUtils.rm_rf('dtr_runners.output')
      pwd = Dir.pwd
      Daemons.run_proc "dtr_runners", :ARGV => ['start'], :backtrace => true  do
        Dir.chdir(pwd) do
          start_runners
        end
      end
    end
  end
  
  def start_server_daemon_mode
    with_daemon_gem do
      Daemons.run_proc "dtr_server", :ARGV => ['start'] do
        start_server
      end
    end
    sleep(2)
  end
  
  def stop_server_daemon_mode
    with_daemon_gem do
      Daemons.run_proc "dtr_server", :ARGV => ['stop']
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
  
  def clean_server
    require 'dtr/service_provider'
    ServiceProvider::Base.new.clear_workspace
  end
  
  module_function :start_server, :start_runners, :launch_runners, :lib_path, :broadcast_list=, :runners, :with_daemon_gem, :start_runners_daemon_mode, :stop_runners_daemon_mode, :start_server_daemon_mode, :stop_server_daemon_mode, :monitor, :port=, :clean_server
end
