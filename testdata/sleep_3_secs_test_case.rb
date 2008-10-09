require 'test/unit'

class Sleep3SecsTestCase < Test::Unit::TestCase

  def test_succeeded
    sleep(3)
  end

end
