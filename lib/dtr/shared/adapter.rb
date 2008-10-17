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

require 'timeout'

module DTR
  module Adapter
    WAKEUP_MESSAGE = 'wakeup'
    SLEEP_MESSAGE = 'sleep'

    module Follower
      def wakeup?
        msg, host, group = listen
        if group == DTR.configuration.group && msg == Adapter::WAKEUP_MESSAGE
          ip, port = host.split(':')
          DTR.configuration.rinda_server_port = port.to_i
          DTR.configuration.broadcast_list = [ip]
          @wakeup_for_host = host
          true
        end
      end

      def sleep?
        return true unless defined?(@wakeup_for_host)
        Timeout.timeout(DTR.configuration.follower_listen_heartbeat_timeout) do
          until (msg, host = listen) && host == @wakeup_for_host; end
          msg == Adapter::SLEEP_MESSAGE
        end
      rescue Timeout::Error => e
        DTR.info "Timeout while listening command"
        true
      end

      def relax
        if defined?(@soc) && @soc
          @soc.close rescue nil
        end
      end

      private
      def listen
        unless defined?(@soc)
          @soc = UDPSocket.open
          @soc.bind('', DTR.configuration.agent_listen_port)
          DTR.info("DTR Agent is listening on port #{DTR.configuration.agent_listen_port}")
        end
        message, client_address = @soc.recvfrom(400)
        cmd, port, group = message.split

        hostname = client_address[2]
        host_ip = client_address[3]
        DTR.info "Received: #{cmd} for group #{group} from #{hostname}(#{host_ip}):#{port}"
        [cmd, "#{host_ip}:#{port}", group]
      end
    end

    module Master
      def hypnotize_agents
        yell_agents("#{Adapter::SLEEP_MESSAGE} #{DTR.configuration.rinda_server_port}")
      end

      def with_wakeup_agents(&block)
        heartbeat = Thread.new do
          loop do
            do_wakeup_agents
            sleep(DTR.configuration.master_heartbeat_interval)
          end
        end
        #heartbeat thread should have high priority for agent is listening
        heartbeat.priority = Thread.current.priority + 10
        block.call
      ensure
        #kill heartbeat first, so that agents wouldn't be wakeup after hypnotized
        Thread.kill heartbeat rescue nil
        hypnotize_agents rescue nil
      end

      def do_wakeup_agents
        yell_agents("#{Adapter::WAKEUP_MESSAGE} #{DTR.configuration.rinda_server_port} #{DTR.configuration.group}")
      end

      private
      def yell_agents(msg)
        DTR.info {"yell agents #{msg}: #{DTR.configuration.broadcast_list.inspect}"}
        DTR.configuration.broadcast_list.each do |it|
          broadcast(it, msg)
        end
      end

      def broadcast(it, msg)
        soc = UDPSocket.open
        begin
          soc.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
          DTR.debug {"broadcast sending #{msg} to #{it}"}
          soc.send(msg, 0, it, DTR.configuration.agent_listen_port)
        rescue
          nil
        ensure
          soc.close
        end
      end
    end
  end
end
