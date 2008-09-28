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

require 'drb'
require 'rinda/ring'
require 'rinda/tuplespace'

module DTR
  module ServiceProvider
    class Base
      PORT = 3344

      attr_accessor :rinda_server_port, :broadcast_list

      def initialize
        env_store = EnvStore.new
        @broadcast_list = []
        (env_store[:broadcast_list] || ['localhost']).each do |broadcast|
          @broadcast_list << broadcast.untaint
        end
        @rinda_server_port = env_store[:port].to_i > 0 ? env_store[:port].to_i : PORT
      end

      def start_rinda
        DTR.info '-- Booting DTR Rinda server...'
        loop do
          begin
            Rinda::RingServer.new Rinda::TupleSpace.new, @rinda_server_port
            break
          rescue Errno::EADDRINUSE
            @rinda_server_port += 1
          end
        end
        DTR.info "-- DTR Rinda server started on port #{@rinda_server_port}"
      end

      def start_service
        DTR.info "-- Start drb service..."
        DRb.start_service
      end

      def stop_service
        DRb.stop_service
      end

      private

      def lookup(method, stuff, timeout=nil)
        lookup_ring.send(method, stuff, timeout)
      end

      def lookup_ring
        @ring ||= lookup_ring_any
      end
      
      def lookup_ring_any
        DTR.info {"broadcast list: #{@broadcast_list.inspect} on port #{rinda_server_port}"}
        Rinda::TupleSpaceProxy.new(Rinda::RingFinger.new(@broadcast_list, rinda_server_port).lookup_ring_any)
      end
    end
  end
end
