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

module DTR
  module ServiceProvider

    module SmartAgent
      AGENT_EAR = 7788

      def hypnotize_agents
        yell_agents("sleep")
      end

      def wakeup_agents
        Thread.start do
          loop do
            yell_agents("wakeup")
            sleep(9)
          end
        end
      end

      def yell_agents(msg)
        DTR.info {"yell agents #{msg}: #{@broadcast_list.inspect}"}
        @broadcast_list.each do |it|
          soc = UDPSocket.open
          begin
            soc.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
            DTR.debug {"broadcast sending #{msg} to #{it}"}
            soc.send(msg, 0, it, AGENT_EAR)
          rescue
            nil
          ensure
            soc.close
          end
        end
      end

      def listen
        unless defined?(@soc)
          @soc = UDPSocket.open
          @soc.bind('', AGENT_EAR)
        end
        @soc.recv(1024)
      end
    end
  end
end
