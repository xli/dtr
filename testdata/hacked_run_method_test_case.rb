require 'test/unit'

class HackedRunMethodTestCase < Test::Unit::TestCase

  alias_method :run_without_hack, :run
  def run(*args, &block)
    UDPSocket.open.bind('', 9999)
    run_without_hack(*args, &block)
  end

  def test_succeeded
  end

end

