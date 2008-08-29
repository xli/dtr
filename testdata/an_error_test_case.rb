require 'test/unit'
class AnErrorTestCase < Test::Unit::TestCase
  class MyError < StandardError
  end
  def test_error
    raise MyError.new('error')
  end
end

