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
  module ServiceProvider
    module Runner
      def provide_runner(runner)
        renewer = Rinda::SimpleRenewer.new
        tuple = [:name, 'DTR::Runner'.to_sym, runner.freeze, "DTR remote runner #{Process.pid}-#{runner.name}"]
        lookup_ring.write(tuple, renewer)
      end

      def lookup_runner
        lookup(:take, [:name, 'DTR::Runner'.to_sym, nil, nil])[2]
      end

      def all_working_runners
        lookup_ring.read_all([:name, 'DTR::Runner'.to_sym, nil, nil]).collect {|rt| rt[2]}
      end
      
      def new_runner_monitor
        lookup_ring.notify(nil, [:name, 'DTR::Runner'.to_sym, nil, nil])
      end
      
      #todo don't use lookup_runner
      def clear_all_working_runners
        all_working_runners.size.times do
          lookup_runner.shutdown rescue nil
        end
      end
    end
  end
end
