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

require 'delegate'

module DTR
  module SyncLogger
    class UndumpedLogger
      include DRbUndumped

      def initialize(logger)
        @logger = logger
      end

      def debug(message=nil, &block)
        @logger.send(:debug, message, &block)
      end

      def info(message=nil, &block)
        @logger.send(:info, message, &block)
      end

      def error(message=nil, &block)
        @logger.send(:error, message, &block)
      end

      def datetime_format=(format)
        @logger.datetime_format = format
      end

      def level=(level)
        @logger.level = level
      end
    end

    module Provider
      def self.included(base)
        base.alias_method_chain :with_rinda_server, :providing_sync_logger
      end

      def with_rinda_server_with_providing_sync_logger(&block)
        with_rinda_server_without_providing_sync_logger do
          lookup_ring.write [:logger, UndumpedLogger.new(DTR.logger)]
          block.call
        end
      end
    end
  end
end
