
require 'test/unit'
class AFileSystemTestCase < Test::Unit::TestCase
  def test_file_exist
    assert File.exist?(File.dirname(__FILE__) + '/a_file_system_test_case.rb')
  end
end

