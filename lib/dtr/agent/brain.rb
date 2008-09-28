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

    class Brain
      include ServiceProvider::SmartAgent
      
      def initialize(runner_names, agent_env_setup_cmd)
        @runner_names = runner_names
        @agent_env_setup_cmd = agent_env_setup_cmd
      end

      def hypnotize
        loop do
          if wakeup?
            DTR.info {"Agent brain wakes up"}
            work(wakeup_worker)
            DTR.info {"Agent brain is going to sleep"}
          end
        end
      rescue Exception => e
        DTR.info {"Agent brain is stopped by Exception => #{e.class.name}, message => #{e.message}"}
      end

      def work(worker)
        until sleep?
          #keep worker working :D
        end
      ensure
        DTR.info {"Killing worker"}
        Process.kill 'TERM', worker
      end
      
      def wakeup_worker
        Process.fork do
          begin
            Worker.new(@runner_names, @agent_env_setup_cmd).launch
          rescue Interrupt, SystemExit, SignalException
          rescue Exception => e
            DTR.info {"Worker is stopped by Exception => #{e.class.name}, message => #{e.message}"}
            DTR.debug {e.backtrace.join("\n")}
          end
        end
      end
    end
  end
end
