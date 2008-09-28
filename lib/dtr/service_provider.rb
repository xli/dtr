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

require 'dtr/ruby_ext'
require 'dtr/utils'
require 'dtr/working_env.rb'
require 'dtr/service_provider/base'
require 'dtr/service_provider/runner'
require 'dtr/service_provider/working_env'
require 'dtr/service_provider/message'
require 'dtr/service_provider/smart_agent'
require 'dtr/service_provider/monitor'

module DTR
  module ServiceProvider
    def broadcast_list=(list)
      EnvStore.new[:broadcast_list] = list
    end

    def port=(port)
      EnvStore.new[:port] = port
    end
    module_function :port=, :broadcast_list=
    
    Base.class_eval do
      include ServiceProvider::WorkingEnv
      include ServiceProvider::SmartAgent
      include ServiceProvider::Runner
      include ServiceProvider::Message
      include ServiceProvider::Monitor
    end
  end
end
