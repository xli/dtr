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
      def self.broadcast_list=(list)
        EnvStore.new[:broadcast_list] = list
      end

      def self.port=(port)
        EnvStore.new[:port] = port
      end

      PORT = 3344

      def initialize
        env_store = EnvStore.new
        @broadcast_list = []
        (env_store[:broadcast_list] || ['localhost']).each do |broadcast|
          @broadcast_list << broadcast.untaint
          DTR.info "-- Added broadcast: #{broadcast}"
        end
        DTR.info "-- Server port: #{server_port}"
      end

      # start DTR server
      def start
        do_start
        #set safe level to 1 here, now, runner can't set to 1, cause test should can do anything
        #......
        $SAFE = 1 unless $DEBUG   # disable eval() and friends
        # Wait until the user explicitly kills the server.
        DRb.thread.join
      end
      
      def do_start
        env_store = EnvStore.new
        DTR.info '-- Booting DTR server...'
        Rinda::RingServer.new Rinda::TupleSpace.new, server_port
        DTR.info "-- DTR server started on port #{server_port}"
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
      
      def server_port
        env_store = EnvStore.new
        env_store[:port].to_i > 0 ? env_store[:port].to_i : PORT
      end

      def lookup_ring
        @ring ||= Rinda::TupleSpaceProxy.new(Rinda::RingFinger.new(@broadcast_list, server_port).lookup_ring_any)
      end
    end
  end
end
