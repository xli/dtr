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

# from activesupport-2.1.1
class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end
end

class NilClass
  def blank?
    true
  end
end

class FalseClass
  def blank?
    true
  end
end

class TrueClass
  def blank?
    false
  end
end

class Array
  alias_method :blank?, :empty?
end

class Hash
  alias_method :blank?, :empty?
end

class String
  def blank?
    self !~ /\S/
  end
end

class Numeric
  def blank?
    false
  end
end

class Module
  # Encapsulates the common pattern of:
  #
  #   alias_method :foo_without_feature, :foo
  #   alias_method :foo, :foo_with_feature
  #
  # With this, you simply do:
  #
  #   alias_method_chain :foo, :feature
  #
  # And both aliases are set up for you.
  #
  # Query and bang methods (foo?, foo!) keep the same punctuation:
  #
  #   alias_method_chain :foo?, :feature
  #
  # is equivalent to
  #
  #   alias_method :foo_without_feature?, :foo?
  #   alias_method :foo?, :foo_with_feature?
  #
  # so you can safely chain foo, foo?, and foo! with the same feature.
  def alias_method_chain(target, feature)
    # Strip out punctuation on predicates or bang methods since
    # e.g. target?_without_feature is not a valid method name.
    aliased_target, punctuation = target.to_s.sub(/([?!=])$/, ''), $1
    yield(aliased_target, punctuation) if block_given?
    
    with_method, without_method = "#{aliased_target}_with_#{feature}#{punctuation}", "#{aliased_target}_without_#{feature}#{punctuation}"
    
    alias_method without_method, target
    alias_method target, with_method
    
    case
      when public_method_defined?(without_method)
        public target
      when protected_method_defined?(without_method)
        protected target
      when private_method_defined?(without_method)
        private target
    end
  end

  # Allows you to make aliases for attributes, which includes 
  # getter, setter, and query methods.
  #
  # Example:
  #
  #   class Content < ActiveRecord::Base
  #     # has a title attribute
  #   end
  #
  #   class Email < Content
  #     alias_attribute :subject, :title
  #   end
  #
  #   e = Email.find(1)
  #   e.title    # => "Superstars"
  #   e.subject  # => "Superstars"
  #   e.subject? # => true
  #   e.subject = "Megastars"
  #   e.title    # => "Megastars"
  def alias_attribute(new_name, old_name)
    module_eval <<-STR, __FILE__, __LINE__+1
      def #{new_name}; self.#{old_name}; end
      def #{new_name}?; self.#{old_name}?; end
      def #{new_name}=(v); self.#{old_name} = v; end
    STR
  end
end
