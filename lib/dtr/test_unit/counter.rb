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

require 'monitor'

module DTR
  module TestUnit
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
  end
end
