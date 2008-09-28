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
      def initialize(working_env_key, message_key=MESSAGE_KEY)
        @working_env_key = working_env_key
        @message_key = message_key
        @env_store = EnvStore.new
        @service = Agent.service_provider
        start_off
      end

      def start_off
        DTR.info "=> Herald starts off..."
        working_env = @service.lookup_working_env
        DTR.debug { "working env: #{working_env}" }
        if working_env[:files].blank?
          DTR.error {"No test files need to load?(working env: #{working_env})"}
          return
        end
        @env_store[@working_env_key] = working_env
      end
    end
  end
end
