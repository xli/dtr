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
    module Monitor
      def monitor
        working_env_monitor = new_working_env_monitor
        Thread.start do
          DTR.info("Current work environment: #{lookup_working_env.inspect}")
          working_env_monitor.each { |t| DTR.info t.inspect }
        end
        message_monitor = new_message_monitor
        Thread.start do
          colors = {}
          base = 30
          message_monitor.each do |t|
            host, message, time = t[1][1..3]
            colors[host] = base+=1 unless colors[host]
            message = "\e[1;31m#{message}\e[0m" if message =~ /-ERROR\]/
            DTR.info "#{time.strftime("[%I:%M:%S%p]")} \e[1;#{colors[host]};1m#{host}\e[0m: #{message}"
          end
        end
        DRb.thread.join
      end
    end
  end
end
