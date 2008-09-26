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

require 'dtr/base'
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

  class ServiceProvider
  
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
    
    def provide(runner)
      renewer = Rinda::SimpleRenewer.new
      tuple = [:name, 'DTR::Runner'.to_sym, runner.freeze, "DTR remote runner #{Process.pid}-#{runner.name}"]
      lookup_ring.write(tuple, renewer)
    end
    
    def send_message(message)
      lookup_ring.write [:agent_heartbeat, Socket.gethostname, message, Time.now], 2
    end
    
    def lookup_runner
      lookup_ring.take([:name, 'DTR::Runner'.to_sym, nil, nil])[2]
    end
    
    def runners
      lookup_ring.read_all([:name, 'DTR::Runner'.to_sym, nil, nil]).collect {|rt| rt[2]}
    end
    
    def monitor
      working_env_monitor = lookup_ring.notify(nil, [:working_env, nil])
      Thread.start do
        DTR.info("Current work environment: #{working_env.inspect}")
        working_env_monitor.each { |t| DTR.info t.inspect }
      end
      if DTROPTIONS[:log_level] == Logger::DEBUG
        runner_monitor = lookup_ring.notify(nil, [:name, 'DTR::Runner'.to_sym, nil, nil])
        Thread.start do
          runner_monitor.each { |t| DTR.debug t.inspect }
        end
      end
      agent_heartbeat_monitor = lookup_ring.notify("write", [:agent_heartbeat, nil, nil, nil])
      Thread.start do
        colors = {}
        base = 30
        agent_heartbeat_monitor.each do |t|
          host, message, time = t[1][1..3]
          colors[host] = base+=1 unless colors[host]
          message = "\e[1;31m#{message}\e[0m" if message =~ /-ERROR\]/
          DTR.info "#{time.strftime("[%I:%M:%S%p]")} \e[1;#{colors[host]};1m#{host}\e[0m: #{message}"
        end
      end
      DRb.thread.join
    end
    
    def wait_until_teardown
      lookup_ring.notify(nil, [:working_env, nil]).pop
    end

    def working_env
      lookup_ring.read([:working_env, nil])[1]
    end
    
    def setup_working_env(env)
      lookup_ring.write [:working_env, env]
      envs = all_working_envs
      if envs.first != env
        unless ENV['DTR_ENV'] == 'test'
          puts "There are other DTR tasks in queue. Your DTR task request has been queued."
          puts "You can use 'dtr -c' to clean all DTR tasks, then your task would be picked up directly."
        end
      end
      
      printing_stars = false
      while(all_working_envs.first != env)
        print '+'
        printing_stars = true
        sleep(5)
      end
      
      if all_working_envs.empty?
        lookup_ring.write [:working_env, env]
      end
      
      unless ENV['DTR_ENV'] == 'test'
        puts '' if printing_stars
        puts 'Showtime, looking for runner service...'
      end
    end
    
    def teardown_working_env
      clear_workspace
    end

    def start_service
      DRb.start_service
    end
    
    def stop_service
      DRb.stop_service
    end
    
    def all_working_envs
      lookup_ring.read_all([:working_env, nil]).collect{|tuple| tuple.last}
    end
    
    def clear_workspace
      all_working_envs.size.times do
        lookup_ring.take [:working_env, nil] rescue nil
      end rescue nil
      runners.size.times do
        lookup_runner.shutdown rescue nil
      end
    end

    private
    def server_port
      env_store = EnvStore.new
      env_store[:port].to_i > 0 ? env_store[:port].to_i : PORT
    end

    def lookup_ring
      Rinda::TupleSpaceProxy.new(Rinda::RingFinger.new(BROADCAST_LIST, server_port).lookup_ring_any)
    end
  end
end
