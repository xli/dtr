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

module DTR
  module Agent
    module WorkingStatus
      WORKING_STATUS_KEY = :runners_working_status
      def runners_should_be_working
        @store[WORKING_STATUS_KEY] = Time.now
      end

      def runners_should_be_working?
        if time = @store[WORKING_STATUS_KEY]
          (time - Time.now) <= follower_listen_heartbeat_timeout
        end
      end

      def agent_is_going_to_sleep
        @store[WORKING_STATUS_KEY] = nil
      end
    end
  end
end