require File.dirname(__FILE__) + '/../test_helper'
include DTR::AgentHelper

class SyncCodebaseTest < Test::Unit::TestCase
  include DTR::Service::File
  include DTR::SyncCodebase::SyncService

  def test_sync_codebase
    testdata_dir = File.expand_path(File.dirname(__FILE__) + '/../../testdata')

    master = Process.fork do
      start_service
      DTR.configuration.start_rinda

      Dir.chdir(testdata_dir) do
        DTR::Cmd.execute('rake dtr_repackage')
        provide_file DTR::SyncCodebase::Codebase.new
        DRb.thread.join
      end
    end
    #sleep for waiting rinda server start
    sleep(1)
    client = Process.fork do
      start_service
      Dir.mkdir("test_sync_codebase")
      Dir.chdir("test_sync_codebase") do
        sync_codebase
      end
    end
    Process.waitpid client
    assert File.directory?("test_sync_codebase/#{package_name}")
    assert !File.exists?("test_sync_codebase/#{package_copy_file}")
  ensure
    stop_service rescue nil
    Process.kill 'TERM', master rescue nil
    FileUtils.rm_rf("test_sync_codebase")
    Dir.chdir(testdata_dir) do
      DTR::Cmd.execute('rake dtr_clobber_package')
    end
  end

  def test_should_not_sync_codebase_and_setup_working_dir_when_agent_is_in_same_dir_with_master_process
    testdata_dir = File.expand_path(File.dirname(__FILE__) + '/../../testdata')
    Dir.chdir(testdata_dir) do
      require 'a_test_case'
      require 'a_test_case2'
      require 'a_file_system_test_case'
    end
    $argv_dup = ['a_test_case.rb', 'a_test_case2.rb', 'a_file_system_test_case.rb']
    suite = Test::Unit::TestSuite.new('run_test_passed')
    suite << ATestCase.suite
    suite << ATestCase2.suite
    suite << AFileSystemTestCase.suite
    @master_dir = "#{testdata_dir}_copy"
    FileUtils.rm_rf(@master_dir)
    FileUtils.cp_r testdata_dir, @master_dir
    @agent = start_agent_at @master_dir, 2, false
    begin
      DTR.inject
      assert_fork_process_exits_ok do
        Dir.chdir(@master_dir) do
          result = runit(suite)
          assert result.passed?
          assert_equal 3, result.run_count
        end
      end
      assert !File.exists?(File.join(@master_dir, Socket.gethostname.gsub(/[^a-zA-Z0-9]/, '_')))
    ensure
      DTR.reject
      Process.kill 'TERM', @agent rescue nil
      Process.waitall
      FileUtils.rm_rf(@master_dir)
    end
  end

end
