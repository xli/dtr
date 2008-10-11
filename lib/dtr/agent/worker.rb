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

module DTR

  module Agent
    # Worker works during one dtr test task running.
    # Worker manages Herald & Runner processes life cycle
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
          DTR.kill_process @herald
          @herald = nil
          DTR.info "=> Herald is killed."
        end
      end

      def run
        @herald = DTR.fork_process { Herald.new @working_env_key, @agent_env_setup_cmd, @runner_names }
        while @env_store[@working_env_key].nil?
          sleep(1)
        end
        working_env = @env_store[@working_env_key]

        @runner_names.each do |name|
          @runner_pids << DTR.fork_process {
            working_env.within do
              Runner.start name, working_env
            end
          }
        end
        Process.waitall
        DTR.info "=> All agent worker sub processes exited."
      end

      def kill_all_runners
        unless @runner_pids.blank?
          @runner_pids.each{ |pid| DTR.kill_process pid }
          DTR.info "=> All runners(#{@runner_pids.join(", ")}) were killed." 
          @runner_pids = []
        end
      end
    end
  end
end
