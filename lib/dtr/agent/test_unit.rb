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

require 'test/unit'
require 'test/unit/testcase'

module DTR
  module Agent
    module TestCaseExt
      include MessageDecorator
      def self.included(base)
        base.alias_method_chain :add_failure, :decorating_source
        base.alias_method_chain :add_error, :decorating_source
      end

      def add_error_with_decorating_source(exception)
        add_error_without_decorating_source(DTR::RemoteError.new(exception))
      end

      def add_failure_with_decorating_source(message, all_locations=caller())
        add_failure_without_decorating_source(decorate_message(message, 'Assertion failure'), all_locations)
      end
    end
  end
end

# set run to true first, so that test auto runner wouldn't work
Test::Unit.run = true
Test::Unit::TestCase.send(:include, DTR::Agent::TestCaseExt)
