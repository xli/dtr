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
    module TestCaseInjection

      def self.included(base)
        base.alias_method_chain :run, :dtr_injection
        #have to use class_eval for adding it back after removed reject_dtr method
        base.class_eval do
          def self.reject_dtr
            remove_method :run
            alias_method :run, :run_without_dtr_injection
            remove_method :run_without_dtr_injection
            (class << self; self; end;).send :remove_method, :reject_dtr
          end
        end
      end

      def run_with_dtr_injection(result, &progress_block)
        DRbTestRunner.new(self, result, &progress_block).run
      end
    end
  end
end
