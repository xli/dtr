Gem::Specification.new do |spec|
  spec.name = 'dtr'
  spec.version = "1.0.0"
  spec.summary = "DTR is a distributed test runner to run tests on distributed computers for decreasing build time."

  #### Dependencies and requirements.
  spec.files = ["lib/dtr/agent/brain.rb", "lib/dtr/agent/herald.rb", "lib/dtr/agent/runner.rb", "lib/dtr/agent/sync_codebase.rb", "lib/dtr/agent/sync_logger.rb", "lib/dtr/agent/test_unit.rb", "lib/dtr/agent/worker.rb", "lib/dtr/agent/working_env_ext.rb", "lib/dtr/agent.rb", "lib/dtr/facade.rb", "lib/dtr/master.rb", "lib/dtr/monitor.rb", "lib/dtr/raketasks.rb", "lib/dtr/shared/adapter.rb", "lib/dtr/shared/configuration.rb", "lib/dtr/shared/message_decorator.rb", "lib/dtr/shared/ruby_ext.rb", "lib/dtr/shared/service/agent.rb", "lib/dtr/shared/service/file.rb", "lib/dtr/shared/service/rinda.rb", "lib/dtr/shared/service/runner.rb", "lib/dtr/shared/service/working_env.rb", "lib/dtr/shared/service.rb", "lib/dtr/shared/sync_codebase/copiable_package.rb", "lib/dtr/shared/sync_codebase/master_ext.rb", "lib/dtr/shared/sync_codebase/package.rb", "lib/dtr/shared/sync_codebase/sync_service.rb", "lib/dtr/shared/sync_codebase.rb", "lib/dtr/shared/sync_logger.rb", "lib/dtr/shared/utils/cmd.rb", "lib/dtr/shared/utils/env_store.rb", "lib/dtr/shared/utils/logger.rb", "lib/dtr/shared/utils.rb", "lib/dtr/shared/working_env.rb", "lib/dtr/shared.rb", "lib/dtr/test_unit/drb_test_runner.rb", "lib/dtr/test_unit/injection.rb", "lib/dtr/test_unit/test_case_injection.rb", "lib/dtr/test_unit/test_suite_injection.rb", "lib/dtr/test_unit/testrunnermediator_injection.rb", "lib/dtr/test_unit/thread_safe_test_result.rb", "lib/dtr/test_unit/worker_club.rb", "lib/dtr/test_unit.rb", "lib/dtr/test_unit_injection.rb", "lib/dtr.rb", "bin/dtr", "CHANGES", "dtr.gemspec", "lib", "LICENSE.TXT", "Rakefile", "README.rdoc", "TODO"]

  spec.test_files = ["test/acceptance/agent_working_env_test.rb", "test/acceptance/dtr_package_task_test.rb", "test/acceptance/general_test.rb", "test/acceptance/raketasks_test.rb", "test/acceptance/sync_codebase_test.rb", "test/acceptance/sync_logger_test.rb", "test/agent_helper.rb", "test/logger_stub.rb", "test/test_helper.rb", "test/unit/adapter_test.rb", "test/unit/configuration_test.rb", "test/unit/facade_test.rb", "test/unit/test_unit_test.rb", "test/unit/working_env_test.rb", "testdata/a_failed_test_case.rb", "testdata/a_file_system_test_case.rb", "testdata/a_test_case.rb", "testdata/a_test_case2.rb", "testdata/an_error_test_case.rb", "testdata/another_project", "testdata/another_project/passed_test_case.rb", "testdata/another_project/Rakefile", "testdata/hacked_run_method_test_case.rb", "testdata/is_required_by_a_test.rb", "testdata/lib", "testdata/lib/lib_test_case.rb", "testdata/package_task_test_rakefile", "testdata/Rakefile", "testdata/raketasks", "testdata/raketasks/Rakefile", "testdata/raketasks/success_test_case.rb", "testdata/scenario_test_case.rb", "testdata/setup_agent_env_test_case.rb", "testdata/sleep_3_secs_test_case.rb", "testdata/verify_dir_pwd", "testdata/verify_dir_pwd/Rakefile", "testdata/verify_dir_pwd/verify_dir_pwd_test_case.rb"]

  #### Load-time details: library and application (you will need one or both).

  spec.require_path = 'lib'                         # Use these for libraries.

  spec.bindir = "bin"                               # Use these for applications.
  spec.executables = ["dtr"]
  spec.default_executable = "dtr"

  #### Documentation and testing.

  spec.has_rdoc = true
  spec.extra_rdoc_files = ["README.rdoc", "LICENSE.txt", "TODO", "CHANGES"]
  spec.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README.rdoc", "--title", "\"DTR -- Distributed Test Runner"]

  #### Author and project details.

  spec.author = "Li Xiao"
  spec.email = "iam@li-xiao.com"
  spec.homepage = "http://github.com/xli/dtr/tree/master"
  spec.rubyforge_project = "dtr"
end
