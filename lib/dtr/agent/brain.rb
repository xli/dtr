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

require 'timeout'
module DTR
  module Agent

    class Brain

      def initialize(runner_names, agent_env_setup_cmd)
        @service = DTR::ServiceProvider::Base.new
        @runner_names = runner_names
        @agent_env_setup_cmd = agent_env_setup_cmd
      end

      def hypnotize
        at_exit {
          Process.kill 'TERM', @worker rescue nil if @worker
        }
        loop do
          next unless @service.listen == "wakeup"

          @worker = wakeup
          DTR.info {"Agent brain waked up"}
          begin
            loop do
              #todo timeout should can be changed
              msg = Timeout.timeout(12) do
                @service.listen
              end
              DTR.info {"Agent brain received: #{msg}"}
              break if msg == 'sleep'
            end
          rescue Timeout::Error => e
          ensure
            DTR.info{"Killing worker"}
            Process.kill 'TERM', @worker
          end
          DTR.info {"Agent brain is going to sleep"}
        end
      end
      
      def wakeup
        Process.fork do
          begin
            DTR.with_monitor do
              Worker.new(@runner_names, @agent_env_setup_cmd).launch
            end
          rescue Interrupt => e
            DTR.info "Interrupt"
            raise e
          rescue SystemExit => e
            DTR.info "SystemExit"
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