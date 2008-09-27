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
  module Agent
    class Heart
      def initialize(key=MESSAGE_KEY)
        @key = key
        @env_store = EnvStore.new
        @provider = Agent.service_provider
        beat
      end
  
      def beat
        loop do
          begin
            if @env_store[@key].blank?
              @provider.send_message('---/V---')
            else
              while message = @env_store[@key].first
                @provider.send_message(message)
                @env_store.shift(@key)
              end
            end
            sleep_any_way
          rescue => e
            DTR.info "Heart lost DTR Server(#{e.message}), going to sleep 10 sec..."
            @env_store[@key] = []
            sleep_any_way
          end
        end
      end
  
      private
      def sleep_any_way
        sleep(10)
      rescue Interrupt => e
        raise e
      rescue SystemExit => e
        raise e
      rescue Exception
      end
    end
  end
end