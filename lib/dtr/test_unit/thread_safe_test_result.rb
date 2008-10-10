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

require 'drb'

module DTR
  module TestUnit
    class ThreadSafeTestResult
      include DRbUndumped

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
  end
end
