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

require 'rinda/ring'

module DTR
  module Service
    module Runner
      include Rinda

      def provide_runner(runner)
        renewer = ::Rinda::SimpleRenewer.new
        tuple = [:name, 'DTR::Runner'.to_sym, runner, "DTR remote runner #{Process.pid}-#{runner.name}"]
        lookup_ring.write(tuple, renewer)
      rescue DRb::DRbConnError
        #lost connection, master process maybe shutdown
        exit
      end

      def lookup_runner
        lookup(:take, [:name, 'DTR::Runner'.to_sym, nil, nil])[2]
      end
    end
  end
end
