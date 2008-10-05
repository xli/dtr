require 'test/unit'
class PassedTestCase < Test::Unit::TestCase
  def test_succeeded
    assert_equal 'test', 'test'
  end
end

