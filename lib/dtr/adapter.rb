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

require 'timeout'

module DTR
  module Adapter
    AGENT_PORT = 7788

    WAKEUP_MESSAGE = 'wakeup'
    SLEEP_MESSAGE = 'sleep'
    YELL_INTERVAL = 10
    LISTEN_SLEEP_TIMEOUT = 15

    module Follower
      def wakeup?
        msg, port = listen
        if msg == Adapter::WAKEUP_MESSAGE
          ServiceProvider.port = port
          true
        end
      end

      def sleep?
        msg_bag = Timeout.timeout(Adapter::LISTEN_SLEEP_TIMEOUT) do
          listen
        end
        DTR.info {"Received: #{msg_bag.inspect}"}
        msg_bag.first == Adapter::SLEEP_MESSAGE
      rescue Timeout::Error => e
        true
      end

      private
      def listen
        unless defined?(@soc)
          @soc = UDPSocket.open
          @soc.bind('', Adapter::AGENT_PORT)
        end
        @soc.recv(1024).split
      end
    end

    module Master
      def hypnotize_agents
        yell_agents(Adapter::SLEEP_MESSAGE)
      end

      def wakeup_agents
        Thread.start do
          loop do
            yell_agents("#{Adapter::WAKEUP_MESSAGE} #{DTR.service_provider.rinda_server_port}")
            sleep(Adapter::YELL_INTERVAL)
          end
        end
      end
      private
      def yell_agents(msg)
        DTR.info {"yell agents #{msg}: #{DTR.service_provider.broadcast_list.inspect}"}
        DTR.service_provider.broadcast_list.each do |it|
          soc = UDPSocket.open
          begin
            soc.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
            DTR.debug {"broadcast sending #{msg} to #{it}"}
            soc.send(msg, 0, it, Adapter::AGENT_PORT)
          rescue
            nil
          ensure
            soc.close
          end
        end
      end
    end
  end
end
