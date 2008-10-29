require File.dirname(__FILE__) + '/../test_helper'

include DTR::AgentHelper

class RailsExtTest < Test::Unit::TestCase
  
  def setup
    DTR.configuration.master_heartbeat_interval = 10
    DTR.configuration.follower_listen_heartbeat_timeout = 15
    start_agents
  end

  def teardown
    DTR.configuration.master_heartbeat_interval = 2
    DTR.configuration.follower_listen_heartbeat_timeout = 3

    stop_agents
  end

  def test_run_dtr_test_task_with_simple_sqlite_project
    new_simple_project do |testdata|
      assert_run_dtr_test_task_success_with(testdata)
    end
  end

  def test_run_dtr_test_task_with_mysql_database
    new_simple_project do |testdata|
      FileUtils.cp_r(testdata + "/config/database.yml.mysql", testdata + "/config/database.yml")
      assert_run_dtr_test_task_success_with(testdata)
      Dir.chdir(agent1_runner1_dir) do
        assert File.exist?('created_by_database_yml_mysql')
      end
    end
  end

  def test_run_dtr_test_task_with_database_yml_dtr_specified
    new_simple_project do |testdata|
      FileUtils.cp_r(testdata + "/config/database.yml.mysql", testdata + "/config/database.yml.dtr")
      assert_run_dtr_test_task_success_with(testdata)
      Dir.chdir(agent1_runner1_dir) do
        assert File.exist?('created_by_database_yml_mysql')
      end
    end
  end

  def assert_run_dtr_test_task_success_with(testdata)
    assert_fork_process_exits_ok do
      Dir.chdir(testdata) do
        output = %x[rake dtr:test DTR_GROUP='#{DTR::AgentHelper::GROUP}' BROADCAST_IP=localhost]
        expected = <<-OUTPUT
5 tests, 7 assertions, 0 failures, 0 errors
OUTPUT
        assert_equal 0, $?.exitstatus
        assert output.include?(expected), "should include #{expected}"
      end
    end
  end

  def new_simple_project
    simple_project = File.expand_path(File.dirname(__FILE__) + '/../../testdata/rails_projects/simple_project')
    testdata = File.expand_path(File.dirname(__FILE__) + '/rails_ext_test')
    FileUtils.rm_rf(testdata)
    FileUtils.cp_r(simple_project, testdata)

    lib_dir = File.expand_path(File.dirname(__FILE__) + '/../../lib')
    tasks_dir = File.expand_path(File.dirname(__FILE__) + '/../../tasks')
    dtr_plugin_dir = testdata + '/vendor/plugins/dtr'
    FileUtils.mkdir_p(dtr_plugin_dir)
    FileUtils.cp_r(lib_dir, dtr_plugin_dir)
    FileUtils.cp_r(tasks_dir, dtr_plugin_dir)

    yield testdata
  ensure
    FileUtils.rm_rf(testdata)
  end
end