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

class Array
  def blank?
    empty?
  end
end

class NilClass
  def blank?
    true
  end
end

class Null
  class << self
    def instance(overrides = {})
      self.new.define_overrides(overrides)
    end  
  end

  #override Object#id for removing the warning
  def id
    nil
  end

  def method_missing(sym, *args, &block)
    nil
  end

  def define_overrides(overrides)
    overrides.each_pair do |key, value|
      (class << self; self; end;).send(:define_method, key, lambda { value })
    end
    self
  end
end
