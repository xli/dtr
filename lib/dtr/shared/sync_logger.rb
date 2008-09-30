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

require 'delegate'

module DTR
  module SyncLogger
    class UndumpedLogger
      include DRbUndumped
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

      def datetime_format=(format)
        @logger.datetime_format = format
      end

      def level=(level)
        @logger.level = level
      end

      private
      def with_decorating_message(level, msg, &block)
        if block_given?
          @logger.send(level) do
            decorate_message(block.call)
          end
        else
          @logger.send(level, decorate_message(msg))
        end
      end
    end

    module Provider
      def self.included(base)
        base.send(:include, Service::Rinda)
        base.alias_method_chain :start_rinda, :providing_sync_logger
      end

      def start_rinda_with_providing_sync_logger
        start_rinda_without_providing_sync_logger
        lookup_ring.write [:logger, UndumpedLogger.new(DTR.logger)]
      end
    end
  end

  Configuration.send(:include, SyncLogger::Provider)
end
