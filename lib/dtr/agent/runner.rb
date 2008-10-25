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
    class Runner
      include DRbUndumped
      include Service::Runner

      attr_reader :name

      def initialize(name)
        @name = name
      end
      
      def start
        #start service first, so that all logs can be sync with master process
        start_service

        ENV['DTR_RUNNER_NAME'] = name
        DTR.configuration.working_env.load_environment do
          provide
          DTR.info {"=> Runner #{name} provided"}
          DRb.thread.join if DRb.thread
        end
      rescue
        DTR.error($!.message)
        DTR.error($!.backtrace.join("\n"))
      ensure
        stop_service
      end

      def run(test, result, &progress_block)
        DTR.debug {"#{name}: running #{test}..."}
        Agent::TestCase.new(test, result, &progress_block).run
        DTR.debug {"#{name}: done #{test}"}
      ensure
        provide
        DTR.debug {"=> Runner #{name} provided"}
      end

      def provide
        provide_runner(self)
      end

      def to_s
        "Runner #{@name}"
      end
    end
  end
end