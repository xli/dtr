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
    class UnknownTestError < StandardError
    end
    class TestCase
      def initialize(test, result, &progress_block)
        @test = test
        @result = result
        @progress_block = progress_block
      end

      def run
        if @test.is_a?(DRb::DRbUnknown)
          add_error(UnknownTestError.new("No such test loaded: #{@test.name}"))
        else
          @test.run(@result, &@progress_block)
        end
      rescue DRb::DRbConnError => e
        msg = "Rescued DRb::DRbConnError(#{e.message}), while running test: #{test}. The master process may be stopped."
        DTR.do_println(msg)
        DTR.info msg
      rescue Exception => e
        unexpected_error(e)
      end

      def unexpected_error(e)
        DTR.error "Unexpected exception: #{e.message}"
        DTR.error e.backtrace.join("\n")
        add_error(e)
      end

      def add_error(e)
        e = RemoteError.new(e)
        @result.add_error(Test::Unit::Error.new(@test.name, e))
        @result.add_run
        @progress_block.call(Test::Unit::TestCase::FINISHED, @test.name)
      end
    end
  end
end