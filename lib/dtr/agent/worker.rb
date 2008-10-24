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
    # Worker manages Herald & Runner processes life cycle.
    class Worker
      def initialize
        @runner_pids = []
        @herald = nil
        @env_store = EnvStore.new
      end

      def launch
        DTR.info {"=> Agent worker started at: #{Dir.pwd}, pid: #{Process.pid}"}
        setup
        begin
          run
        ensure
          teardown
          DTR.info {"Agent worker is dieing"}
        end
      end

      private
      def setup
        DTR.configuration.working_env = nil
      end

      def teardown
        unless @runner_pids.blank?
          @runner_pids.each{ |pid| DTR.kill_process pid }
          DTR.info {"=> All runners(#{@runner_pids.join(", ")}) were killed." }
          @runner_pids = []
        end
        if @herald
          DTR.kill_process @herald
          @herald = nil
          DTR.info {"=> Herald is killed."}
        end
      end

      def run
        herald
        runners
        DTR.info {"=> All agent worker sub processes exited."}
      end

      def herald
        @herald = DTR.fork_process { Herald.new }
        Process.waitpid @herald
        exit(-1) unless $?.exitstatus == 0
      end

      def runners
        DTR.configuration.agent_runners.each do |name|
          @runner_pids << DTR.fork_process {
            at_exit {
              # exit anyway, for DRb may hang on the process to be a deadwalk
              exit!
            }
            working_env = DTR.configuration.working_env
            working_env.within do
              Runner.start name, working_env
            end
          }
        end
        Process.waitall
      end
    end
  end
end
