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

  module Agent
    class Worker
      def initialize(runner_names, agent_env_setup_cmd)
        @runner_names = runner_names.is_a?(Array) ? runner_names : [runner_names.to_s]
        @agent_env_setup_cmd = agent_env_setup_cmd
        @runner_pids = []
        @herald = nil
        @working_env_key = :working_env
        @env_store = EnvStore.new
      end

      def launch
        DTR.info "=> Agent worker started at: #{Dir.pwd}, pid: #{Process.pid}"
        setup
        begin
          run
        ensure
          teardown
          DTR.info "Agent worker is dieing"
        end
      end

      private
      def setup
        @env_store[@working_env_key] = nil
      end

      def teardown
        kill_all_runners
        if @herald
          Process.kill 'TERM', @herald rescue nil
          @herald = nil
          DTR.info "=> Herald is killed."
        end
      end

      def run
        @herald = drb_fork { Herald.new @working_env_key, @agent_env_setup_cmd, @runner_names }
        while @env_store[@working_env_key].nil?
          sleep(1)
        end
        working_env = @env_store[@working_env_key]

        @runner_names.each do |name|
          @runner_pids << drb_fork {
            working_env.within do
              Runner.start name, working_env
            end
          }
        end
        Process.waitall
      end

      def kill_all_runners
        unless @runner_pids.blank?
          @runner_pids.each{ |pid| Process.kill 'TERM', pid rescue nil }
          DTR.info "=> All runners(#{@runner_pids.join(", ")}) were killed." 
          @runner_pids = []
        end
      end

      def drb_fork
        Process.fork do
          begin
            yield
          rescue Interrupt, SystemExit, SignalException
          rescue Exception => e
            DTR.error "Worker drb fork is stopped by Exception => #{e.class.name}, message => #{e.message}"
            DTR.debug e.backtrace.join("\n")
          end
        end
      end
    end
  end
end
