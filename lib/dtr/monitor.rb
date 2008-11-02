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
  
  # Monitor provides a way to monitor agent/master process working status.
  class Monitor

    class AgentsMonitor
      include Adapter::Master

      def start
        Process.fork do
          monitor
        end
      end
      def monitor
        DTR.configuration.with_rinda_server do
          with_wakeup_agents do
            begin
              sleep
            rescue Interrupt
            end
          end
        end
      end
    end

    class MasterMonitor
      include Adapter::Follower
      include Service::Agent

      def start
        Process.fork do
          begin
            loop do
              monitor
            end
          rescue Errno::EADDRINUSE
            puts "There is DTR agent started on this machine."
            puts "Shutdown it for monitoring working DTR Master info."
          rescue Interrupt
          ensure
            relax
          end
        end
      end

      def monitor
        msg, from_host, group = listen
        unless ["127.0.0.1:#{DTR.configuration.rinda_server_port}"].include?(from_host)
          puts "Master process message from #{from_host}: #{msg} for group #{group}"
          ip, port = from_host.split(':')
          with_configuration(ip, port) do
            start_service
            puts "Agents working for #{from_host}: "
            puts all_agents_info.collect{|i| "  #{i.strip}"}.join("\n")
          end
        end
      end

      def with_configuration(ip, port)
        my_port = DTR.configuration.rinda_server_port
        my_broadcast_list = DTR.configuration.broadcast_list
        DTR.configuration.rinda_server_port = port.to_i
        DTR.configuration.broadcast_list = [ip]
        yield
      ensure
        DTR.configuration.broadcast_list = my_broadcast_list
        DTR.configuration.rinda_server_port = my_port
      end
    end

    def start
      MasterMonitor.new.start
      AgentsMonitor.new.start
      puts "Monitor process started at #{Time.now}"
      Process.waitall
    rescue Interrupt
    end
  end
end
