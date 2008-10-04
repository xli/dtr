require File.dirname(__FILE__) + '/../test_helper'

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

    client = Process.fork do
      start_service
      Dir.mkdir("test_sync_codebase")
      Dir.chdir("test_sync_codebase") do
        sync_codebase
      end
    end
    Process.waitpid client
    assert File.exists?("test_sync_codebase/#{package_copy_file}")
  ensure
    stop_service rescue nil
    Process.kill 'TERM', master rescue nil
    FileUtils.rm_rf("test_sync_codebase")
    Dir.chdir(testdata_dir) do
      DTR::Cmd.execute('rake dtr_clobber_package')
    end
  end

end
