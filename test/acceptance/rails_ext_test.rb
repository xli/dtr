require File.dirname(__FILE__) + '/../test_helper'

include DTR::AgentHelper

class RailsExtTest < Test::Unit::TestCase
  
  def setup
    start_agents
  end

  def test_run_dtr_test_task_with_simple_project
    simple_project = File.expand_path(File.dirname(__FILE__) + '/../../testdata/rails_projects/simple_project')
    testdata = File.expand_path(File.dirname(__FILE__) + '/rails_ext_test')
    FileUtils.cp_r(simple_project, testdata)
    lib_dir = File.expand_path(File.dirname(__FILE__) + '/../../lib')
    tasks_dir = File.expand_path(File.dirname(__FILE__) + '/../../tasks')
    
    dtr_plugin_dir = testdata + '/simple_project/vendor/plugins/dtr'
    FileUtils.mkdir_p(dtr_plugin_dir)
    FileUtils.cp_r(lib_dir, dtr_plugin_dir)
    FileUtils.cp_r(tasks_dir, dtr_plugin_dir)

    assert_fork_process_exits_ok do
      ENV['BROADCAST_IP'] = 'localhost'
      ENV['DTR_GROUP'] = DTR::AgentHelper::GROUP

      Dir.chdir(testdata + '/simple_project') do
        output = %x[rake dtr:test]
        puts output
        expected = <<-OUTPUT
5 tests, 7 assertions, 0 failures, 0 errors
OUTPUT
        assert_equal 0, $?.exitstatus
        assert output.include?(expected), "should include #{expected}"
      end
    end
  ensure
    FileUtils.rm_rf(testdata)
  end

  def teardown
    stop_agents
  end
end