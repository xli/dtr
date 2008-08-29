require 'test/unit'
require File.dirname(__FILE__) + '/is_required_by_a_test.rb'
class ATestCase < Test::Unit::TestCase

  def test_succeeded
    require 'pp'
    assert eval('true')
    assert IsRequiredByATest.ok?
    assert_equal 'test', ENV["RAILS_ENV"]
  end

end

