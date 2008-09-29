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

require 'dtr/adapter'

module DTR
  module Master
    include Adapter::Master

    def with_dtr_task_injection(&block)
      if defined?(ActiveRecord::Base)
        ActiveRecord::Base.clear_active_connections! rescue nil
      end
      DTR.service_provider.start_rinda
      yelling = wakeup_agents
      DTR.service_provider.provide_working_env WorkingEnv.new
      DTR.info {"Master process started at #{Time.now}"}

      block.call
    ensure
      DTR.info {"stop yelling"}
      Thread.kill yelling rescue nil
      hypnotize_agents rescue nil
      DTR.service_provider.stop_service rescue nil
      DTR.info { "==> all done" }
    end
  end
end