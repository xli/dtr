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
require 'dtr/service_provider'
require 'test/unit'
require 'drb'

class Test::Unit::TestCase
  alias_method :add_error_without_hack, :add_error
  def add_error(exception)
    add_error_without_hack(DTR::RunnerRuntimeException.new(exception))
  end

  alias_method :add_failure_without_hack, :add_failure
  def add_failure(message, all_locations=caller())
    add_failure_without_hack(DTR.decorate_error_message(message, 'Assertion failure'), all_locations)
  end
end

module DTR
  
  def service_provider
    ServiceProvider.new
  end
  
  module_function :service_provider

  class RunnerAgent
    
    def self.start(runner_names=["Distributed Test Runner"], agent_env_setup_cmd=nil)
      DTR.with_monitor do 
        new(runner_names, agent_env_setup_cmd).launch
      end
    end
    
    def initialize(runner_names, agent_env_setup_cmd)
      @runner_names = runner_names.is_a?(Array) ? runner_names : [runner_names.to_s]
      @agent_env_setup_cmd = agent_env_setup_cmd
      @runner_pids = []
      @herald = nil
      @working_env_key = :working_env
      @env_store = EnvStore.new
      @agent_pid = Process.pid
      at_exit {
        if Process.pid == @agent_pid
          DTR.info "*** Runner agent is stopping ***"
          kill_all_runners
          if @herald
            Process.kill 'KILL', @herald rescue nil
            DTR.info "=> Herald is killed." 
          end
          if @heart
            Process.kill 'KILL', @heart rescue nil
            DTR.info "=> Heartbeat is stopped." 
          end
          DTR.info "*** Runner agent stopped ***"
        end
      }
    end
    
    def launch
      DTR.info "=> Runner agent started at: #{Dir.pwd}, pid: #{Process.pid}"
      @heart = drb_fork { Heart.new }
      @herald = drb_fork { Herald.new @working_env_key }
      working_env = {}
      @env_store[@working_env_key] = nil
      loop do
        if @env_store[@working_env_key] && working_env[:identifier] != @env_store[@working_env_key][:identifier]
          working_env = @env_store[@working_env_key]

          DTR.info "=> Got new working environment created at #{working_env[:created_at]}"

          kill_all_runners
          ENV['DTR_MASTER_ENV'] = working_env[:dtr_master_env]

          if Cmd.execute(@agent_env_setup_cmd || working_env[:agent_env_setup_cmd])
            @runner_names.each do |name| 
              @runner_pids << drb_fork { Runner.start name, working_env }
            end
          else
            DTR.info {'No runners started.'}
          end
        end
        sleep(2)
      end
    end
    
    private
    
    def kill_all_runners
      unless @runner_pids.blank?
        @runner_pids.each{ |pid| Process.kill 'KILL', pid rescue nil }
        DTR.info "=> All runners(#{@runner_pids.join(", ")}) were killed." 
        @runner_pids = []
      end
    end
    
    def drb_fork
      Process.fork do
        at_exit {
          DRb.stop_service
          exit!
        }
        begin
          yield
        rescue Interrupt => e
          raise e
        rescue SystemExit => e
          raise e
        rescue Exception => e
          DTR.error "Got an Exception #{e.message}:"
          DTR.error e.backtrace.join("\n")
          raise e
        end
      end
    end
  end
  
  class Heart
    def initialize(key=MESSAGE_KEY)
      @key = key
      @env_store = EnvStore.new
      @provider = DTR.service_provider
      beat
    end
    
    def beat
      loop do
        begin
          if @env_store[@key].blank?
            @provider.send_message('---/V---')
          else
            while message = @env_store[@key].first
              @provider.send_message(message)
              @env_store.shift(@key)
            end
          end
          sleep_any_way
        rescue => e
          DTR.info "Heart lost DTR Server(#{e.message}), going to sleep 10 sec..."
          @env_store[@key] = []
          sleep_any_way
        end
      end
    end
    
    private
    def sleep_any_way
      sleep(10)
    rescue Exception
    end
  end
  
  class Herald
    
    def initialize(key)
      @key = key
      @env_store = EnvStore.new
      @env_store[@key] = nil
      @provider = DTR.service_provider
      start_off
    end
    
    def start_off
      loop do
        DTR.info "=> Herald starts off..."
        begin
          working_env = @provider.working_env
          DTR.debug { "working env: #{working_env.inspect}" }
          if working_env[:files].blank?
            DTR.error "No test files need to load?(working env: #{working_env.inspect})"
          else
            @env_store[@key] = working_env if @env_store[@key].nil? || @env_store[@key][:identifier] != working_env[:identifier]
            @provider.wait_until_teardown
          end

          sleep(2)
        rescue => e
          DTR.info "Herald lost DTR Server(#{e.message}), going to sleep 5 sec..."
          sleep(5)
        end
      end
    end
  end
  
  class Runner
    include DRbUndumped
    
    def self.start(name, env)
      DTR.info "#{name}: Initialize working environment..."
      env[:libs].select{ |lib| !$LOAD_PATH.include?(lib) && File.exists?(lib) }.each do |lib|
        $LOAD_PATH << lib
        DTR.debug {"#{name}: appended lib: #{lib}"}
      end
      DTR.info "#{name}: libs loaded"
      DTR.debug {"#{name}: $LOAD_PATH: #{$LOAD_PATH.inspect}"}
      
      env[:files].each do |f|
        begin
          load f unless f =~ /^-/
          DTR.debug {"#{name}: loaded #{f}"}
        rescue LoadError => e
          DTR.error "#{name}: No such file to load -- #{f} (Environment: #{env.inspect})"
        end
      end
      DTR.info "#{name}: test files loaded"

      @provider = DTR.service_provider

      @provider.provide(self.new(@provider, name, env[:identifier]))
      DTR.info "=> Runner #{name} provided"
      DRb.thread.join if DRb.thread
    end
    
    attr_reader :name, :identifier
    
    def initialize(provider, name, identifier)
      Test::Unit.run = true
      @name = name
      @provider = provider
      @identifier = identifier
      @started = []
      @run_finished = []
    end
    
    def run(test, result, &progress_block)
      DTR.debug {"#{name}: running #{test}..."}
      @started << test.name
      test.run(result, &progress_block)
    rescue DRb::DRbConnError => e
      DTR.info{ "Rescued DRb::DRbConnError(#{e.message}), while running test: #{test.name}. The master process may be stopped." }
    rescue Exception => e
      DTR.error {"Unexpected exception: #{e.message}"}
      DTR.error {e.backtrace.join("\n")}
      result.add_error(Test::Unit::Error.new(test.name, e))
      result.add_run
      progress_block.call(Test::Unit::TestCase::FINISHED, test.name)
    ensure
      DTR.debug {"#{name}: done #{test}"}
      @run_finished << test.name
      @provider.provide(self)
    end
    
    def reboot
      DTR.info "#{self} is rebooting. Ran #{@started.size} tests, finished #{@run_finished.size}."
      @provider.provide(self)
    end
    
    def shutdown
      DTR.info "#{self} is shutting down. Ran #{@started.size} tests, finished #{@run_finished.size}."
      @provider.stop_service rescue exit!
    end
    
    def to_s
      "Runner #{@name}"
    end
  end
end
