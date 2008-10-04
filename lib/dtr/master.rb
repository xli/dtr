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
    def with_dtr_master(&block)
      #require working_env_ext only when need it, otherwise how could we test working_env without ext?
      #todo: figure out better way, shouldn't make it complex for test
      require 'dtr/working_env_ext'
      if defined?(ActiveRecord::Base)
        ActiveRecord::Base.clear_active_connections! rescue nil
      end

      DTR.info {"Master process started at #{Time.now}"}

      start_service
      DTR.configuration.start_rinda
      provide_working_env WorkingEnv.new
      yelling_thread = wakeup_agents
      block.call
    ensure
      #kill yelling_thread first, so that agents wouldn't be wakeup after were hypnotized
      Thread.kill yelling_thread rescue nil
      hypnotize_agents rescue nil
      stop_service rescue nil
    end

    include Adapter::Master
    include Service::WorkingEnv
    include SyncCodebase::MasterExt
  end

  Configuration.send(:include, SyncLogger::Provider)
end
