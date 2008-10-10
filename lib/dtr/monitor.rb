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

require 'dtr/master'

module DTR
  class Monitor
    include Adapter::Master
    include Service::Agent
    def start
      DTR.configuration.with_rinda_server do
        monitor_thread = Thread.new do
          new_agent_monitor.each { |t| puts t.last.last }
        end
        puts "Monitor process started at #{Time.now}"
      
        with_wakeup_agents do
          begin
            monitor_thread.join
          rescue Interrupt
          end
        end
      end
    end
  end
end
