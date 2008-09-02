Gem::Specification.new do |spec|
  spec.name = 'dtr'
  spec.version = "0.0.4"
  spec.summary = "DTR is a distributed test runner to run tests on distributed computers for decreasing build time."

  #### Dependencies and requirements.

  spec.add_dependency('daemons', '> 1.0.7')
  #s.requirements << ""

  #### Which files are to be included in this gem?  Everything!  (Except SVN directories.)

  spec.files = ["lib/dtr/base.rb", "lib/dtr/raketasks.rb", "lib/dtr/runner.rb", "lib/dtr/service_provider.rb", "lib/dtr/test_unit.rb", "lib/dtr/test_unit_injection.rb", "lib/dtr.rb", "bin/dtr", "bin", "CHANGES", "doc", "dtr.gemspec", "install.rb", "lib", "LICENSE.TXT", "Rakefile", "README", "TODO"]

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