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
  class CmdInterrupt < StandardError; end

  class Cmd
    def self.execute(cmd)
      return true if cmd.nil? || cmd.empty?
      DTR.info "Executing: #{cmd.inspect}"
      output = %x[#{cmd} 2>&1]
      # don't put the following message into a block which maybe passed to remote process
      status = $?.exitstatus
      DTR.info "Execution is done, status: #{status}"
      DTR.error "#{cmd.inspect} output:\n#{output}" if status != 0
      $?.exitstatus == 0
    end
  end
end
