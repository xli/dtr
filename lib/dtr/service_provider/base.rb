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
require 'socket'

module DTR
  def decorate_error_message(msg, source=nil)
    source ? "#{source} from #{Socket.gethostname}: #{msg}" : "From #{Socket.gethostname}: #{msg}"
  end
  
  module_function :decorate_error_message

  class RunnerRuntimeException < StandardError
    def initialize(e)
      super(DTR.decorate_error_message(e.message, e.class.name))
      set_backtrace(e.backtrace)
    end
  end

  module ServiceProvider
    class Base
      def self.broadcast_list=(list)
        EnvStore.new[:broadcast_list] = list
      end

      def self.port=(port)
        EnvStore.new[:port] = port
      end

      PORT = 3344
      BROADCAST_LIST = []

      def initialize
        DTR.info "-- Initializing drb service..."
        env_store = EnvStore.new
        (env_store[:broadcast_list] || ['localhost']).each do |broadcast|
          BROADCAST_LIST << broadcast.untaint
          DTR.info "-- Added broadcast: #{broadcast}"
        end
        DTR.info "-- Server port: #{server_port}"
        DRb.start_service
      end

      # start DTR server
      def start
        env_store = EnvStore.new
        DTR.info '-- Booting DTR server...'
        Rinda::RingServer.new Rinda::TupleSpace.new, server_port
        DTR.info "-- DTR server started on port #{server_port}"
        #set safe level to 1 here, now, runner can't set to 1, cause test should can do anything
        #......
        $SAFE = 1 unless $DEBUG   # disable eval() and friends
        # Wait until the user explicitly kills the server.
        DRb.thread.join
      end

      def start_service
        DRb.start_service
      end

      def stop_service
        DRb.stop_service
      end

      private
      
      def lookup(method, stuff, timeout=10)
        timeout = 10
        until obj = lookup_ring.send(method, stuff, timeout)
          sleep(1)
        end
        obj
      end
      
      def server_port
        env_store = EnvStore.new
        env_store[:port].to_i > 0 ? env_store[:port].to_i : PORT
      end

      def lookup_ring
        @ring ||= Rinda::TupleSpaceProxy.new(Rinda::RingFinger.new(BROADCAST_LIST, server_port).lookup_ring_any)
      end
    end
  end
end
