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
    module WorkingEnv
      
      class WorkingEnvProvider
        def initialize(working_env, service_provider)
          @working_env = working_env
          @service_provider = service_provider
        end
        
        def apply
          do_apply
          at_exit {
            @service_provider.teardown_working_env
          }
          need_wait = false
          until our_turn?
            unless need_wait
              need_wait = true
              DTR.do_print "There are other DTR tasks in queue. Your DTR task request has been queued.\n"
              DTR.do_print "You can use 'dtr -c' to clean all DTR tasks, then your task would be picked up directly.\n"
            end
            DTR.do_print '+'
            sleep(5)
          end

          DTR.do_print "\n" if need_wait
          DTR.do_print "Showtime, looking for runner service..."
          self
        end
        
        def working?
          envs = @service_provider.all_working_envs
          envs.first && envs.first == @working_env
        end

        private
        def our_turn?
          envs = @service_provider.all_working_envs
          if envs.first
            envs.first == @working_env
          else
            do_apply
            false
          end
        end

        def do_apply
          @service_provider.provide_working_env @working_env
        end
      end
      
      def setup_working_env(env)
        WorkingEnvProvider.new(env, self).apply
      end
      
      def new_working_env_monitor
        lookup_ring.notify(nil, [:working_env, nil])
      end

      def wait_until_teardown
        lookup_ring.notify(nil, [:working_env, nil]).pop
      end

      def lookup_working_env
        lookup(:read, [:working_env, nil])[1]
      end
      
      def provide_working_env(env)
        lookup_ring.write [:working_env, env]
      end

      def teardown_working_env
        lookup_ring.take [:working_env, nil] rescue nil
        clear_all_working_runners
      end

      def clear_workspace
        all_working_envs.size.times do
          lookup_ring.take [:working_env, nil] rescue nil
        end rescue nil
        clear_all_working_runners
      end

      def all_working_envs
        lookup_ring.read_all([:working_env, nil]).collect{|tuple| tuple.last}
      end
    end
  end
  
end
