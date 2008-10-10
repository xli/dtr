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

require 'dtr/shared'

module DTR
  module Master
    def with_dtr_master(&block)
      if defined?(ActiveRecord::Base)
        ActiveRecord::Base.clear_active_connections! rescue nil
      end

      DTR.info ""
      DTR.info "--------------------beautiful line--------------------------"
      DTR.info {"Master process started at #{Time.now}"}

      DTR.configuration.with_rinda_server do
        provide_working_env WorkingEnv.new
        with_wakeup_agents(&block)
      end
    end

    include Adapter::Master
    include Service::WorkingEnv
    include SyncCodebase::MasterExt
  end

  Configuration.send(:include, SyncLogger::Provider)
end
