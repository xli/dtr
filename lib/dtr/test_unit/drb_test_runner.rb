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
  module TestUnit
    class DRbTestRunner
      include Service::Runner

      def initialize(test, result, &progress_block)
        @test = test
        @result = result
        @progress_block = progress_block
      end

      def run
        if runner = lookup_runner
          WorkerClub.instance.start_thread(self, runner)
        else
          self.run
        end
      end

      def run_test_on(runner)
        runner.run(@test, @result.instance(runner), &@progress_block)
      rescue DRb::DRbConnError => e
        DTR.info {"#{cause.class.name}(#{cause.message}), rerun test: #{@test.name}"}
        DTR.debug { cause.backtrace.join("\n") }
        self.run
      rescue Exception => e
        DTR.info{ "#{@test.name}, rescue an exception: #{e.message}, add error into result." }
        @result.add_error(Test::Unit::Error.new(@test.name, e))
        @result.add_run
        @progress_block.call(Test::Unit::TestCase::FINISHED, @test.name)
      end
    end
  end
end
