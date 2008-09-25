Gem::Specification.new do |spec|
  spec.name = 'dtr'
  spec.version = "0.0.5"
  spec.summary = "DTR is a distributed test runner to run tests on distributed computers for decreasing build time."

  #### Dependencies and requirements.

  spec.add_dependency('daemons', '> 1.0.7')
  #s.requirements << ""
  # p Dir.glob("lib/**/*.rb") + Dir.glob("test/**/*.rb") + Dir.glob("testdata/**/*")
  spec.files =  ["lib/dtr/base.rb", "lib/dtr/raketasks.rb", "lib/dtr/runner.rb", "lib/dtr/service_provider.rb", "lib/dtr/test_unit.rb", "lib/dtr/test_unit_injection.rb", "lib/dtr.rb", "test/base_test.rb", "test/logger_test.rb", "test/scenario_tests.rb", "test/test_helper.rb", "test/test_unit_test.rb", "testdata/a.zip", "testdata/a_failed_test_case.rb", "testdata/a_file_system_test_case.rb", "testdata/a_test_case.rb", "testdata/a_test_case2.rb", "testdata/an_error_test_case.rb", "testdata/is_required_by_a_test.rb", "testdata/lib", "testdata/lib/lib_test_case.rb", "testdata/Rakefile", "testdata/scenario_test_case.rb", "testdata/setup_agent_env_test_case.rb"] + ["lib/dtr.rb", "bin/dtr", "bin", "CHANGES", "doc", "dtr.gemspec", "install.rb", "lib", "LICENSE.TXT", "Rakefile", "README", "TODO"]

  #### Load-time details: library and application (you will need one or both).

  spec.require_path = 'lib'                         # Use these for libraries.

  spec.bindir = "bin"                               # Use these for applications.
  spec.executables = ["dtr"]
  spec.default_executable = "dtr"

  #### Documentation and testing.

  spec.has_rdoc = false

  #### Author and project details.

  spec.author = "Li Xiao"
  spec.email = "iam@li-xiao.com"
  spec.homepage = "http://github.com/xli/dtr/tree/master"
  spec.rubyforge_project = "dtr"
end