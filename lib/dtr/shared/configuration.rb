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

require 'singleton'
require 'rinda/rinda'
require 'rinda/tuplespace'

module DTR

  def configuration
    Configuration.instance
  end

  module_function :configuration

  class Configuration
    include Singleton

    attr_accessor :broadcast_list, :rinda_server_port, :master_yell_interval, :follower_listen_sleep_timeout

    def initialize
      store = EnvStore.new
      @broadcast_list = store[:broadcast_list] || ['localhost']
      @rinda_server_port = store[:port] || 3344
      @master_yell_interval = store[:master_yell_interval] || 10
      @follower_listen_sleep_timeout =  store[:follower_listen_sleep_timeout] || 15
    end

    def save
      store = EnvStore.new
      store[:broadcast_list] = @broadcast_list
      store[:port] = @rinda_server_port
      store[:master_yell_interval] = @master_yell_interval
      store[:follower_listen_sleep_timeout] = @follower_listen_sleep_timeout
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

    def lookup_ring_any
      DTR.info {"broadcast list: #{@broadcast_list.inspect} on port #{@rinda_server_port}"}
      @ring ||= ::Rinda::TupleSpaceProxy.new(Rinda::RingFinger.new(@broadcast_list, @rinda_server_port).lookup_ring_any)
    end

  end
end