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
    module TestRunnerMediatorInjection

      class SuiteWrapper
        def initialize(suite)
          @suite = suite
        end
        def run(result, &block)
          @suite.run(result, &block)
          @result.graceful_shutdown
        end
      end

      def self.included(base)
        base.send(:include, Master)
        base.alias_method_chain :create_result, :thread_safe
        base.alias_method_chain :run_suite, :dtr_injection
        #have to use class_eval for adding it back after removed reject_dtr method
        base.class_eval do
          def self.reject_dtr
            remove_method :run_suite
            alias_method :run_suite, :run_suite_without_dtr_injection
            remove_method :run_suite_without_dtr_injection

            remove_method :create_result
            alias_method :create_result, :create_result_without_thread_safe
            remove_method :create_result_without_thread_safe

            (class << self; self; end;).send :remove_method, :reject_dtr
          end
        end
      end

      def create_result_with_thread_safe
        ThreadSafeTestResult.new(create_result_without_thread_safe)
      end

      def run_suite_with_dtr_injection
        DTR.logger('dtr_master_process.log')
        @suite
        with_dtr_master do
          run_suite_without_dtr_injection
        end
      end
    end
  end
end
