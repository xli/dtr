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

require 'dtr/master'
require 'test/unit/testcase'
require 'test/unit/util/observable'
require 'monitor'
require 'drb'
require 'timeout'

DTROPTIONS = {} unless defined?(DTROPTIONS)
DTROPTIONS[:log_file] = 'dtr_master_process.log' unless DTROPTIONS[:log_file]

module DTR
  def reject
    return unless Test::Unit::TestSuite.method_defined?(:dtr_injected?)
    Test::Unit::TestCase.send(:include, Rejection)
    Test::Unit::TestSuite.send(:include, Rejection)
  end
  
  def inject
    return if Test::Unit::TestSuite.method_defined?(:dtr_injected?)
    Test::Unit::TestCase.send(:include, TestCaseInjection)
    Test::Unit::TestSuite.send(:include, TestSuiteInjection)
  end
  
  def service
    return $dtr_service if defined?($dtr_service)
    $dtr_service = DTR::Service::Base.new
  end

  module_function :reject, :inject, :service
  
  class Counter
    
    def initialize
      extend MonitorMixin
      @start_count, @finish_count = 0, 0
      @complete_cond = new_cond
    end

    def add_start_count
      synchronize do
        @start_count += 1
      end
    end

    def add_finish_count
      synchronize do
        @finish_count += 1
        @complete_cond.signal
      end
    end
    
    def to_s
      synchronize do
        status
      end
    end
    
    def wait_until_complete(&block)
      synchronize do
        @complete_cond.wait_until do
          complete?
        end
      end
    end
    
    private
    def complete?
      DTR.info{ "Counter status: #{status}" }
      @finish_count >= @start_count
    end
    
    def status
      "finish_count => #{@finish_count}, start_count => #{@start_count}"
    end
  end
  
  class ThreadSafeTestResult
    include Test::Unit::Util::Observable
    include DRbUndumped

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
  end

  class DRbTestRunner
    include Service::Runner
    
    # because some test case will rewrite TestCase#run to ignore some tests, which
    # makes TestResult#run_count different with TestSuite#size, so we need to count
    # by ourselves.(for example: ActionController::IntegrationTest)
    class << self
      def counter
        @counter ||= Counter.new
      end
    end
    
    RUN_TEST_FINISHED = "::DRbTestRunner::RUN_TEST_FINISHED"
    DEFAULT_RUN_TEST_TIMEOUT = 60 #seconds
    
    def initialize(test, result, &progress_block)
      @test = test
      @result = result
      @progress_block = progress_block
      
      DRbTestRunner.counter.add_start_count
    end
    
    def run
      if runner = lookup_runner
        run_test_on(runner)
      else
        self.run
      end
    end
    
    def run_test_on(runner)
      Thread.start do
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
  
  module TestCaseInjection
    
    def self.included(base)
      base.alias_method_chain :run, :dtr_injection
    end

    def run_with_dtr_injection(result, &progress_block)
      DTR.debug {"start of run TestCase(#{name})"}
      DRbTestRunner.new(self, result, &progress_block).run
      DTR.debug {"end of run TestCase(#{name})"}
    end
  end

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
      DTR.info { "start of run suite(#{name}), size: #{size};"}
      if result.kind_of?(ThreadSafeTestResult)
        run_without_dtr_injection(result, &progress_block)
      else
        with_dtr_task_injection do
          result = ThreadSafeTestResult.new(result)
          run_without_dtr_injection(result) do |channel, value|
            DTR.debug { "=> channel: #{channel}, value: #{value}" }
            progress_block.call(channel, value)
            if channel == DTR::DRbTestRunner::RUN_TEST_FINISHED
              DRbTestRunner.counter.add_finish_count
            end
          end
          DRbTestRunner.counter.wait_until_complete
        end
      end
      DTR.info { "end of run suite(#{name}), test result status: #{result}, counter status: #{DRbTestRunner.counter}"}
    end
  end
  
  module Rejection
    def self.included(base)
      base.class_eval do
        remove_method :dtr_injected? if base.method_defined?(:dtr_injected?)
        remove_method :run
        alias_method :run, :run_without_dtr_injection
        remove_method :run_without_dtr_injection
      end
    end
  end
end
