require File.dirname(__FILE__) + '/../test_helper'
require 'dtr/agent/rails_ext'

class DatabaseInitializerTest < Test::Unit::TestCase
  include DTR::Agent::RailsExt::DatabaseInitializer

  def test_should_be_nil_when_no_config_database_yml_and_database_yml_dtr_exist
    assert_nil preparing_database_command
  end

  def test_should_overwrite_config_database_yml_if_config_database_yml_dtr_exists
    FileUtils.mkdir_p('config')
    File.open('config/database.yml', 'w+') do |io|
      io.syswrite("database.yml")
    end
    File.open('config/database.yml.dtr', 'w+') do |io|
      io.syswrite("database.yml.dtr")
    end
    assert_not_nil preparing_database_command
    assert_equal 'database.yml.dtr', File.new('config/database.yml').read
  ensure
    FileUtils.rm_rf('config')
  end

  def test_should_include_runner_name_in_environment
    ENV['DTR_RUNNER_NAME'] = 'runner_name'
    FileUtils.mkdir_p('config')
    File.open('config/database.yml', 'w+') do |io|
      io.syswrite("database.yml")
    end
    assert_equal "rake db:create db:migrate db:test:prepare DTR_RUNNER_NAME=runner_name",  preparing_database_command
  ensure
    ENV['DTR_RUNNER_NAME'] = nil
    FileUtils.rm_rf('config')
  end
end
