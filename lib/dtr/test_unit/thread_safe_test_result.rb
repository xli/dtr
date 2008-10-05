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

require 'test/unit/testresult'
require 'test/unit/util/observable'
require 'drb'

module DTR
  module TestUnit
    class ThreadSafeTestResult
      include Test::Unit::Util::Observable
      include DRbUndumped
      include WorkerClub

      def initialize(rs)
        extend MonitorMixin
        @rs = rs
        @channels = @rs.send(:channels).dup
        @rs.send(:channels).clear
      end

      def add_run
        synchronize do
          @rs.add_run
        end  
        notify_listeners(Test::Unit::TestResult::CHANGED, self)
      end

      def add_failure(failure)
        synchronize do
          @rs.add_failure(failure)
        end  
        notify_listeners(Test::Unit::TestResult::FAULT, failure)
        notify_listeners(Test::Unit::TestResult::CHANGED, self)
      end

      def add_error(error)
        synchronize do
          @rs.add_error(error)
        end  
        notify_listeners(Test::Unit::TestResult::FAULT, error)
        notify_listeners(Test::Unit::TestResult::CHANGED, self)
      end

      def add_assertion
        synchronize do
          @rs.add_assertion
        end  
        notify_listeners(Test::Unit::TestResult::CHANGED, self)
      end

      def to_s
        synchronize do
          @rs.to_s
        end  
      end

      def passed?
        synchronize do
          @rs.passed?
        end  
      end

      def failure_count
        synchronize do
          @rs.failure_count
        end  
      end

      def error_count
        synchronize do
          @rs.error_count
        end  
      end

      def run_count
        synchronize do
          @rs.run_count
        end  
      end

      def assertion_count
        synchronize do
          @rs.assertion_count
        end  
      end

      def errors
        synchronize do
          @rs.errors
        end  
      end

      def failures
        synchronize do
          @rs.failures
        end  
      end
    end
  end
end
