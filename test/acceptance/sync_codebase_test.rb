require File.dirname(__FILE__) + '/../test_helper'
include DTR::AgentHelper

class SyncCodebaseTest < Test::Unit::TestCase
  include DTR::Service::File
  include DTR::SyncCodebase::SyncService

  def test_sync_codebase
    testdata_dir = File.expand_path(File.dirname(__FILE__) + '/../../testdata')

    master = Process.fork do
      DTR.configuration.with_rinda_server do
        Dir.chdir(testdata_dir) do
          DTR::Cmd.execute('rake dtr_repackage')
          provide_file DTR::SyncCodebase::CopiablePackage.new
          DRb.thread.join
        end
      end
    end
    #sleep for waiting rinda server start
    sleep(1)
    client = Process.fork do
      start_service
      Dir.mkdir("test_sync_codebase")
      Dir.chdir("test_sync_codebase") do
        sync_codebase do
          do_work(unpackage_cmd(package_name))
        end
      end
    end
    Process.waitpid client
    assert File.directory?("test_sync_codebase/#{package_name}")
    assert !File.exists?("test_sync_codebase/#{package_copy_file}")
  ensure
    stop_service rescue nil
    DTR.kill_process master
    DTR.kill_process client
    FileUtils.rm_rf("test_sync_codebase")
    Dir.chdir(testdata_dir) do
      DTR::Cmd.execute('rake dtr_clobber_package')
    end
  end

  #todo: do we need this?
  def xtest_should_not_sync_codebase_and_setup_working_dir_when_agent_is_in_same_dir_with_master_process
    @master_dir = File.expand_path(File.dirname(__FILE__) + '/../../testdata/verify_dir_pwd')
    @agent = start_agent_at @master_dir, 2, false
    begin
      assert_fork_process_exits_ok do
        Dir.chdir(@master_dir) do
          require 'verify_dir_pwd_test_case'
        end
        $argv_dup = ['verify_dir_pwd_test_case.rb']
        suite = Test::Unit::TestSuite.new('test_should_not_sync_codebase_and_setup_working_dir')
        suite << VerifyDirPwdTestCase.suite

        Dir.chdir(@master_dir) do
          result = runit(suite)
          assert result.passed?
          assert_equal 1, result.run_count
        end
      end
    ensure
      DTR.kill_process @agent
      Process.waitall
    end
  end

end
