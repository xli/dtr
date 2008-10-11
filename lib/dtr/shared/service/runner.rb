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

require 'rinda/ring'

module DTR
  module Service
    module Runner
      include Rinda

      def provide_runner(runner)
        tuple = ['DTR::Runner'.to_sym, runner, "DTR remote runner #{Process.pid}-#{runner.name}"]
        #expires after 1 sec for we don't need runner service anymore if there is no one is waiting for taking it
        lookup_ring.write(tuple, 1)
      end

      def lookup_runner
        lookup(:take, ['DTR::Runner'.to_sym, nil, nil])[1]
      end

    end
  end
end
