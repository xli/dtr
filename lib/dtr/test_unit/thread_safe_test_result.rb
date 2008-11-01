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
    class SynchronizedTestResult
      def initialize(rs)
        @mutex = Mutex.new
        @rs = rs
      end

      def to_s
        @mutex.synchronize do
          @rs.to_s
        end
      end

      def method_missing(method, *args, &block)
        @mutex.synchronize do
          @rs.send(method, *args, &block)
        end
      end
    end

    class ThreadSafeTestResult < SynchronizedTestResult

      class Pair
        include DRbUndumped

        def initialize(rs1, rs2)
          @rs1 = rs1
          @rs2 = rs2
        end

        def to_s
          @rs1.to_s
        end

        def method_missing(method, *args, &block)
          @rs1.send(method, *args, &block)
          @rs2.send(method, *args, &block)
        end
      end

      class RunnerTestResults

        def initialize
          @results = {}
        end

        def fetch(runner)
          @results[runner_id(runner)] ||= SynchronizedTestResult.new(Test::Unit::TestResult.new)
        end

        def to_s
          @results.sort_by{|runner_id, result| -result.run_count}.collect do |runner_id, result|
            "#{runner_id} => #{result}"
          end.join("\n")
        end

        def runner_id(runner)
          runner.instance_variable_get('@uri').gsub(/^druby:\/\//, '')
        end
      end

      def initialize(*args)
        super
        @results = RunnerTestResults.new
      end

      def instance(runner)
        Pair.new(self, @results.fetch(runner))
      end

      def to_s
        "#{@results}\n\n#{super}"
      end
    end
  end
end
