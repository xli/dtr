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
    class Base
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
          if @env_store[@working_env_key] && working_env != @env_store[@working_env_key]
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
  end
end
