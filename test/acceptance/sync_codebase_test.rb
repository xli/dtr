require File.dirname(__FILE__) + '/../test_helper'
include DTR::AgentHelper

class SyncCodebaseTest < Test::Unit::TestCase
  include DTR::Service::File
  include DTR::SyncCodebase::SyncService

  def test_sync_codebase
    testdata_dir = File.expand_path(File.dirname(__FILE__) + '/../../testdata')

    master = Process.fork do
      Dir.chdir(testdata_dir) do
        DTR.root = Dir.pwd
        DTR.configuration.with_rinda_server do
          DTR::Cmd.execute('rake dtr_repackage')
          provide_file DTR::SyncCodebase::CopiablePackage.new
          DRb.thread.join
        end
      end
    end
    #sleep for waiting rinda server start
    sleep(1)
    client = Process.fork do
      Dir.mkdir("test_sync_codebase")
      Dir.chdir("test_sync_codebase") do
        DTR.root = Dir.pwd
        start_service
        sync_codebase do
          do_work(unpackage_cmd)
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
end
