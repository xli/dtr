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

require 'dtr/shared'

module DTR
  module Master
    include Adapter::Master
    include Service::WorkingEnv

    def with_dtr_task_injection(&block)
      if defined?(ActiveRecord::Base)
        ActiveRecord::Base.clear_active_connections! rescue nil
      end

      start_service
      DTR.configuration.start_rinda
      provide_working_env WorkingEnv.new
      yelling_thread = wakeup_agents

      DTR.info {"Master process started at #{Time.now}"}

      block.call
    ensure
      DTR.info {"stop yelling"}
      Thread.kill yelling_thread rescue nil
      hypnotize_agents rescue nil
      stop_service rescue nil
      DTR.info { "==> all done" }
    end
  end
end