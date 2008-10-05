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

require 'test/unit/testcase'
require 'test/unit/testsuite'

module DTR
  def reject
    return unless Test::Unit::TestSuite.method_defined?(:dtr_injected?)
    Test::Unit::TestCase.send(:include, TestUnit::Rejection)
    Test::Unit::TestSuite.send(:include, TestUnit::Rejection)
  end

  def inject
    return if Test::Unit::TestSuite.method_defined?(:dtr_injected?)
    Test::Unit::TestCase.send(:include, TestUnit::TestCaseInjection)
    Test::Unit::TestSuite.send(:include, TestUnit::TestSuiteInjection)
  end

  module_function :reject, :inject

  module TestUnit
    module Rejection
      def self.included(base)
        base.send(:remove_method, :dtr_injected?) if base.method_defined?(:dtr_injected?)
        base.send(:remove_method, :run)
        base.send(:alias_method, :run, :run_without_dtr_injection)
        base.send(:remove_method, :run_without_dtr_injection)
      end
    end
  end
end
