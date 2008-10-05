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
  module TestUnit
    module TestSuiteInjection
      def self.included(base)
        base.send(:include, Master)
        base.alias_method_chain :run, :dtr_injection
        base.class_eval do
          def dtr_injected?
            true
          end
        end
      end

      def run_with_dtr_injection(result, &progress_block)
        if result.kind_of?(ThreadSafeTestResult)
          run_without_dtr_injection(result, &progress_block)
        else
          DTR.logger('dtr_master_process.log')
          with_dtr_master do
            result = ThreadSafeTestResult.new(result)
            run_without_dtr_injection(result) do |channel, value|
              DTR.debug { "=> channel: #{channel}, value: #{value}" }
              progress_block.call(channel, value)
              if channel == DRbTestRunner::RUN_TEST_FINISHED
                DRbTestRunner.counter.add_finish_count
              end
            end
            DRbTestRunner.counter.wait_until_complete
          end
        end
        DTR.info { "suite(#{name}): result => #{result}, counter status => #{DRbTestRunner.counter}"}
      end
    end
  end
end
