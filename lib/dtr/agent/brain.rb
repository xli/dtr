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

    class Brain
      include Adapter::Follower
      
      def initialize(runner_names)
        raise 'No runner? What can I do for you?' if runner_names.blank?
        @runner_names = runner_names
        DTR.info {""}
        DTR.info {"--------------------beautiful line--------------------------"}
        DTR.info {"=> Agent environment setup command: #{DTR.configuration.agent_env_setup_cmd}"}
        DTR.info {"=> Runner names: #{@runner_names.join(', ')}"}
        DTR.info {"=> Broadcast list: #{DTR.configuration.broadcast_list.inspect}"}
        DTR.info {"=> Listening port: #{DTR.configuration.agent_listen_port}"}
        DTR.info {"=> Group: #{DTR.configuration.group}"}
      end

      def hypnotize
        loop do
          if wakeup?
            DTR.info {"Agent brain wakes up"}
            work(DTR.fork_process { Worker.new(@runner_names).launch })
            DTR.info {"Agent brain is going to sleep"}
          end
        end
      rescue Interrupt, SystemExit, SignalException
      ensure
        relax
      end

      def work(worker)
        until sleep?
          #keep worker working :D
        end
      ensure
        DTR.info {"Killing worker"}
        DTR.kill_process worker
      end
    end
  end
end
