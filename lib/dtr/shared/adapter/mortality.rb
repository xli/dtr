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

require 'timeout'

module DTR
  module Adapter
    DEAD_MESSAGE = 'die'

    module Follower
      private

      def listen_with_dead_message
        cmd, host, group = listen_without_dead_message
        if cmd == Adapter::DEAD_MESSAGE && group == DTR.configuration.group
          DTR.info{"Master need me die. So I am dieing."}
          raise Interrupt, "Master need me die."
        end
        [cmd, host, group]
      end
      alias_method_chain :listen, :dead_message
    end

    module Master
      def group_agents_should_die(group = DTR.configuration.group)
        yell_agents("#{Adapter::DEAD_MESSAGE} #{DTR.configuration.rinda_server_port} #{group}")
      end
    end
  end
end
