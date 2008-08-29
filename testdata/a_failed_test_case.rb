require 'test/unit'
class AFailedTestCase < Test::Unit::TestCase
  def test_failed
    assert false
  end
end


