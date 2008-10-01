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
  module Service
    module Agent
      include Rinda
      def new_agent_monitor
        lookup_ring.notify(nil, [:agent, nil])
      end

      def provide_agent_info(setup_env_cmd, runners)
        agent = %{
- agent(host at #{Socket.gethostname}):
    default setup environment command: '#{setup_env_cmd}'
    runners: #{runners.inspect}
}
        lookup_ring.write [:agent, agent]
      end
    end
  end
end
