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
  module MessageDecorator
    def decorate_message(msg, source=nil)
      source ? "#{source} from #{Socket.gethostname}: #{msg}" : "From #{Socket.gethostname}: #{msg}"
    end
  end
  class RemoteError < StandardError
    include MessageDecorator
    def initialize(e)
      super(decorate_message(e.message, e.class.name))
      set_backtrace(e.backtrace)
    end
  end
end
