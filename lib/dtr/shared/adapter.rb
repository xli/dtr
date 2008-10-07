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

    module Follower
      def wakeup?
        msg, host = listen
        if msg == Adapter::WAKEUP_MESSAGE
          port = host.split(':').last.to_i
          DTR.configuration.rinda_server_port = port
          @wakeup_for_host = host
          true
        end
      end

      def sleep?
        return true unless defined?(@wakeup_for_host)
        msg, host = Timeout.timeout(DTR.configuration.follower_listen_sleep_timeout) do
          loop do
            msg, host = listen
            break if host == @wakeup_for_host
          end
          [msg, host]
        end
        DTR.info "Received: #{msg} from #{host}"
        msg == Adapter::SLEEP_MESSAGE
      rescue Timeout::Error => e
        DTR.info "Timeout while listening command"
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
        yell_agents("#{Adapter::SLEEP_MESSAGE} #{host}")
      end

      def with_wakeup_agents(&block)
        yelling = Process.fork do
          loop do
            do_wakeup_agents
            sleep(DTR.configuration.master_yell_interval)
          end
        end
        block.call
      ensure
        #kill yelling_process first, so that agents wouldn't be wakeup after were hypnotized
        Process.kill 'TERM', yelling rescue nil
        hypnotize_agents rescue nil
      end

      def do_wakeup_agents
        yell_agents("#{Adapter::WAKEUP_MESSAGE} #{host}")
      end

      private
      def yell_agents(msg)
        DTR.info {"yell agents #{msg}: #{DTR.configuration.broadcast_list.inspect}"}
        DTR.configuration.broadcast_list.each do |it|
          broadcast(it, msg)
        end
      end

      def host
        "#{Socket.gethostname}:#{DTR.configuration.rinda_server_port}"
      end

      def broadcast(it, msg)
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
