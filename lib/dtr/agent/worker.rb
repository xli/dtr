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
    # Worker watchs runner processes.
    class Worker
      def initialize
        @runners_group = ThreadGroup.new
      end

      def watch_runners
        DTR.configuration.agent_runners.each do |name|
          runner_thread = Thread.start { DTR.run_script("DTR::Agent::Runner.new(#{name.inspect}).start") }
          runner_thread[:runner_name] = name
          @runners_group.add runner_thread
        end

        yield

        while @runners_group.list.length > 0
          alive_runners = @runners_group.list.collect {|r| r[:runner_name]}
          DTR.info { "Waiting for #{alive_runners.join(', ').downcase} shutdown" }
          sleep 1
        end
      end
    end
  end
end
