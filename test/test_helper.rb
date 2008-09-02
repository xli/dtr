require 'test/unit'
require 'logger'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../testdata')

require 'rubygems'
require 'growling_test'

ENV['DTR_ENV'] = 'test'

module Test
  module Unit
    class TestCase
      def assert_false(o)
        assert !o
      end
    end
  end
end
