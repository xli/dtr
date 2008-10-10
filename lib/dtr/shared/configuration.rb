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
    include Service::Rinda

    attr_accessor :broadcast_list, :rinda_server_port, :master_heartbeat_interval, :follower_listen_heartbeat_timeout

    def initialize
      store = EnvStore.new
      # always have 'localhost' in broadcast_list, for our master process would start rinda server locally,
      # and dtr should work well on local machine when the machine leaves dtr grid network environment.
      @broadcast_list = ['localhost'].concat(store[:broadcast_list] || []).uniq
      @rinda_server_port = store[:port] || 3344
      @master_heartbeat_interval = store[:master_heartbeat_interval] || 10
      @follower_listen_heartbeat_timeout =  store[:follower_listen_heartbeat_timeout] || 15
    end

    def save
      store = EnvStore.new
      store[:broadcast_list] = @broadcast_list
      store[:port] = @rinda_server_port
      store[:master_heartbeat_interval] = @master_heartbeat_interval
      store[:follower_listen_heartbeat_timeout] = @follower_listen_heartbeat_timeout
    end

    def with_rinda_server(&block)
      DTR.do_println("Booting DTR service")
      start_service
      DTR.info '-- Booting DTR Rinda server'
      loop do
        begin
          Rinda::RingServer.new Rinda::TupleSpace.new, @rinda_server_port
          break
        rescue Errno::EADDRINUSE
          @rinda_server_port += 1
        end
      end
      DTR.info "-- DTR Rinda server started on port #{@rinda_server_port}"
      block.call
    ensure
      stop_service rescue nil
    end

    def lookup_ring_any
      @ring ||= __lookup_ring_any__
    end

    private
    def __lookup_ring_any__
      DTR.info {"broadcast list: #{@broadcast_list.inspect} on port #{@rinda_server_port}"}
      ::Rinda::TupleSpaceProxy.new(Rinda::RingFinger.new(@broadcast_list, @rinda_server_port).lookup_ring_any)
    end
  end
end