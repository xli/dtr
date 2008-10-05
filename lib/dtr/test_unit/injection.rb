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
require 'test/unit/ui/testrunnermediator'

module DTR
  def reject
    return unless Test::Unit::UI::TestRunnerMediator.respond_to?(:reject_dtr)
    Test::Unit::UI::TestRunnerMediator.reject_dtr
    Test::Unit::TestCase.reject_dtr
  end

  def inject
    return if Test::Unit::UI::TestRunnerMediator.respond_to?(:reject_dtr)
    Test::Unit::UI::TestRunnerMediator.send(:include, TestUnit::TestRunnerMediatorInjection)
    Test::Unit::TestCase.send(:include, TestUnit::TestCaseInjection)
  end

  module_function :reject, :inject
end