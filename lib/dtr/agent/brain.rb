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

    class Brain < ProcessRoot
      include Adapter::Follower
      
      def initialize
        super
        DTR.logger('dtr_agent.log')
        raise 'No runner? What can I do for you?' if DTR.configuration.agent_runners.blank?
        DTR.info {""}
        DTR.info {"--------------------beautiful line--------------------------"}
        DTR.info {"=> Agent environment setup command: #{DTR.configuration.agent_env_setup_cmd}"}
        DTR.info {"=> Runners: #{DTR.configuration.agent_runners.join(', ')}"}
        DTR.info {"=> Listening port: #{DTR.configuration.agent_listen_port}"}
        DTR.info {"=> Group: #{DTR.configuration.group}"}
        DTR.info {"=> Dir.pwd: #{Dir.pwd}"}
      end

      def hypnotize
        with_relaxation do
          loop do
            do_once
          end
        end
      end

      def hypnotize_once
        with_relaxation do
          do_once
        end
      end

      private
      def do_once
        if wakeup?
          DTR.info {"Agent brain wakes up"}

          if DTR.run_script("DTR::Agent::Herald.new")
            fang_gou
          else
            DTR.info {"=> No runner started."}
          end

          DTR.info {"Agent brain is going to sleep"}
        end
      end

      def with_relaxation
        yield
      rescue Interrupt, SystemExit, SignalException
        DTR.info {$!.message}
      ensure
        relax
        DTR.info {"Agent brain is dieing."}
      end

      def fang_gou
        DTR.configuration.runners_should_be_working
        Worker.new.watch_runners do
          until sleep?
            DTR.configuration.runners_should_be_working
          end
          DTR.configuration.agent_is_going_to_sleep
        end
      end
    end
  end
end
