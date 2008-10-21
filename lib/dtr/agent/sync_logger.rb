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
  module SyncLogger

    # Synchronizer loads SyncLogger provided by master process from Rinda server.
    # Any process need sync logs with master process should start service first,
    # so that local logger could be replaced by SyncLogger.
    # For logs would be sent back to master process, all messages would be sent
    # as string message. The message logged as block would be converted to string
    # message.
    module Synchronizer
      def self.included(base)
        base.alias_method_chain :start_service, :sync_logger
      end

      def start_service_with_sync_logger
        start_service_without_sync_logger
        if logger_tuple = lookup_ring.read_all([:logger, nil]).first
          sync_logger = logger_tuple[1]
          DTR.logger = MessageDecoratedLogger.new(sync_logger)
        end
      end
    end

    class MessageDecoratedLogger
      include MessageDecorator

      def initialize(logger)
        @logger = logger
      end

      def debug(message=nil, &block)
        with_decorating_message(:debug, message, &block)
      end

      def info(message=nil, &block)
        with_decorating_message(:info, message, &block)
      end

      def error(message=nil, &block)
        with_decorating_message(:error, message, &block)
      end

      def level
        @logger_level ||= @logger.level
      end

      private
      def with_decorating_message(level, msg, &block)
        raise 'Should not use block to send log remotely' if block_given?
        @logger.send(level, decorate_message(msg))
      end
    end
  end

  Service::Rinda.send(:include, SyncLogger::Synchronizer)
end
