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

  module Agent
    class Herald
      def initialize(key)
        @key = key
        @env_store = EnvStore.new
        @env_store[@key] = nil
        @provider = Agent.service_provider
        start_off
      end

      def start_off
        loop do
          DTR.info "=> Herald starts off..."
          begin
            working_env = @provider.lookup_working_env
            DTR.debug { "working env: #{working_env.inspect}" }
            if working_env[:files].blank?
              DTR.error "No test files need to load?(working env: #{working_env.inspect})"
            else
              @env_store[@key] = working_env if @env_store[@key].nil? || @env_store[@key] != working_env
              @provider.wait_until_teardown
            end

            sleep(2)
          rescue => e
            DTR.info "Herald lost DTR Server(#{e.message}), going to sleep 5 sec..."
            sleep(5)
          end
        end
      end
    end
  end
end
