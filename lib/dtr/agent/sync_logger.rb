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
  module SyncLogger

    # Synchronizer loads SyncLogger from master process
    # Any process need sync logs with master process should start service first.
    # For logs would be sent back to master process, output log code should use 
    # message string instead of block, for example: 
    #    right: DTR.debug 'message'
    #    not:   DTR.debug { 'message' }
    module Synchronizer
      def self.included(base)
        base.alias_method_chain :start_service, :sync_logger
      end

      def start_service_with_sync_logger
        start_service_without_sync_logger
        if logger_tuple = lookup_ring.read_all([:logger, nil]).first
          sync_logger = logger_tuple[1]
          DTR.logger = sync_logger
        end
      end
    end
  end

  Service::Rinda.send(:include, SyncLogger::Synchronizer)
end
