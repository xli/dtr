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

require 'drb'
require 'rinda/ring'

module DTR
  module Service
    module Rinda

      def start_service
        DTR.info "-- Start drb service..."
        # for ruby 1.8.7 need specify uri
        DRb.start_service("druby://#{Socket.gethostname}:0")
      end

      def stop_service
        DRb.stop_service
      end

      def lookup(method, stuff, timeout=nil)
        lookup_ring.send(method, stuff, timeout)
      end

      def lookup_ring
        DTR.configuration.lookup_ring_any
      end
    end
  end
end
