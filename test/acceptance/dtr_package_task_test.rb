require File.dirname(__FILE__) + '/../test_helper'
require 'fileutils'

class DTRPackageTaskTest < Test::Unit::TestCase
  def test_package
    testdata_dir = File.expand_path(File.dirname(__FILE__) + '/../../testdata')
    Dir.chdir(testdata_dir) do
      %x[rake -q --rakefile package_task_test_rakefile dtr_package]
      assert File.exists?(testdata_dir + "/dtr_pkg/codebase-dump/a_test_case2.rb")
      assert File.exists?(testdata_dir + "/dtr_pkg/codebase-dump/lib/lib_test_case.rb")
      assert File.exists?(testdata_dir + "/dtr_pkg/codebase-dump/is_required_by_a_test.rb")

      assert File.exists?(testdata_dir + "/dtr_pkg/codebase-dump.zip")

      %x[rake -q --rakefile package_task_test_rakefile dtr_clobber_package]

      assert !File.exists?(testdata_dir + "/dtr_pkg/codebase-dump/a_test_case2.rb")
      assert !File.exists?(testdata_dir + "/dtr_pkg/codebase-dump/lib/lib_test_case.rb")
      assert !File.exists?(testdata_dir + "/dtr_pkg/codebase-dump/is_required_by_a_test.rb")

      assert !File.exists?(testdata_dir + "/dtr_pkg/codebase-dump.zip")
    end
  ensure
    FileUtils.rm_rf(testdata_dir + "/dtr_pkg") rescue nil
  end

  def test_should_not_include_dtr_pkg_dir
    testdata_dir = File.expand_path(File.dirname(__FILE__) + '/../../testdata')
    Dir.chdir(testdata_dir) do
      %x[rake -q dtr_repackage]
      assert !File.exists?(testdata_dir + "/dtr_pkg/codebase-dump/dtr_pkg")
    end
  ensure
    FileUtils.rm_rf(testdata_dir + "/dtr_pkg") rescue nil
  end
end
