require 'test/unit'

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../testdata')

require 'rubygems'
require 'growling_test'
require 'dtr'

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
