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

      def self.start(name, env)
        self.new(name, env).start
        DRb.thread.join if DRb.thread
      end

      attr_reader :name, :identifier

      def initialize(name, env)
        @name = name
        @identifier = env[:identifier]
        @env = env
      end
      
      def start
        #start service first, so that all logs can be sync with master process
        start_service
        DTR.info("=> Starting runner #{name} at #{Dir.pwd}, pid: #{Process.pid}")
        init_environment
        provide
      rescue Exception
        DTR.error($!.message)
        DTR.error($!.backtrace.join("\n"))
      end

      def init_environment
        DTR.info {"#{name}: Initialize working environment..."}
        @env[:libs].select{ |lib| !$LOAD_PATH.include?(lib) && File.exists?(lib) }.each do |lib|
          $LOAD_PATH << lib
          DTR.debug {"#{name}: appended lib: #{lib}"}
        end
        DTR.info {"#{name}: libs loaded"}
        DTR.debug {"#{name}: $LOAD_PATH: #{$LOAD_PATH.inspect}"}

        @env[:files].each do |f|
          begin
            load f unless f =~ /^-/
            DTR.debug {"#{name}: loaded #{f}"}
          rescue LoadError => e
            DTR.error {"#{name}: No such file to load -- #{f}"}
            DTR.debug {"Environment: #{@env}"}
          end
        end
        DTR.info {"#{name}: test files loaded"}
      end

      def run(test, result, &progress_block)
        DTR.debug {"#{name}: running #{test}..."}
        Agent::TestCase.new(test, result, &progress_block).run
        DTR.debug {"#{name}: done #{test}"}
      ensure
        provide
      end

      def provide
        provide_runner(self)
        DTR.info {"=> Runner #{name} provided"}
      end

      def to_s
        "Runner #{@name}"
      end
    end
  end
end