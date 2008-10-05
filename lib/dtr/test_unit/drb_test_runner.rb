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
  module TestUnit
    class DRbTestRunner
      include Service::Runner

      RUN_TEST_FINISHED = "::DRbTestRunner::RUN_TEST_FINISHED"
      DEFAULT_RUN_TEST_TIMEOUT = 60 #seconds

      def initialize(test, result, &progress_block)
        @test = test
        @result = result
        @progress_block = progress_block
      end

      def run
        if runner = lookup_runner
          run_test_on(runner)
        else
          self.run
        end
      end

      def run_test_on(runner)
        @result.start_thread do
          begin
            Timeout.timeout(ENV['RUN_TEST_TIMEOUT'] || DEFAULT_RUN_TEST_TIMEOUT) do
              runner.run(@test, @result, &@progress_block)
            end
            @progress_block.call(RUN_TEST_FINISHED, @test.name)
          rescue Timeout::Error => e
            DTR.info {"Run test timeout(#{ENV['RUN_TEST_TIMEOUT'] || DEFAULT_RUN_TEST_TIMEOUT}), reboot runner"}
            runner.reboot rescue nil
            DTR.info {"rerun test: #{@test.name}"}
            self.run
          rescue DRb::DRbConnError => e
            DTR.info {"DRb::DRbConnError(#{e.message}), rerun test: #{@test.name}"}
            self.run
          rescue Exception => e
            DTR.info{ "#{test.name}, rescue an exception: #{e.message}, add error into result." }
            @result.add_error(Test::Unit::Error.new(@test.name, e))
            @result.add_run
            @progress_block.call(Test::Unit::TestCase::FINISHED, @test.name)
            @progress_block.call(RUN_TEST_FINISHED, @test.name)
          end
        end
      end
    end
  end
end
