require File.dirname(__FILE__) + '/../test_helper'
include DTR::AgentHelper

class RakeTasksTest < Test::Unit::TestCase
  def test_test_task
    FileUtils.mkdir_p("raketasks_test_agent")
    Dir.chdir('raketasks_test_agent') do
      start_agents
    end
    test_dir = File.expand_path(File.dirname(__FILE__) + '/../../testdata/raketasks')
    Dir.chdir(test_dir) do
      output = %x[rake dtr]
      expected = <<-OUTPUT
1 tests, 1 assertions, 0 failures, 0 errors
OUTPUT
      assert_equal 0, $?.exitstatus
      assert output.include?(expected), "should include #{expected}"
    end
  ensure
    stop_agents
    FileUtils.rm_rf("raketasks_test_agent")
  end

  def test_test_task_with_processes
    test_dir = File.expand_path(File.dirname(__FILE__) + '/../../testdata/raketasks')
    Dir.chdir(test_dir) do
      output = %x[rake dtr P=3]
      expected = <<-OUTPUT
1 tests, 1 assertions, 0 failures, 0 errors
OUTPUT
      assert_equal 0, $?.exitstatus
      assert output.include?(expected), "should include #{expected}"
    end
  ensure
    FileUtils.rm_rf("#{test_dir}/#{Socket.gethostname.gsub(/[^\d\w]/, '_')}")
  end
end