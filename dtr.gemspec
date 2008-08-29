require 'rubygems'
require 'rake'

#### Basic information.

Gem::Specification.new do |spec|
  spec.name = 'dtr'
  spec.version = "0.0.4"
  spec.summary = "DTR is a distributed test runner to run tests on distributed computers for decreasing build time."

  #### Dependencies and requirements.

  spec.add_dependency('daemons', '> 1.0.7')
  #s.requirements << ""

  #### Which files are to be included in this gem?  Everything!  (Except SVN directories.)

  spec.files = FileList['lib/**/*.rb', 'lib/**/*.rake', 'bin/*', '[a-zA-Z]*'].to_a

  #### Load-time details: library and application (you will need one or both).

  spec.require_path = 'lib'                         # Use these for libraries.

  spec.bindir = "bin"                               # Use these for applications.
  spec.executables = ["dtr"]
  spec.default_executable = "dtr"

  #### Documentation and testing.

  spec.has_rdoc = false

  #### Author and project details.

  spec.author = "Li Xiao"
  spec.email = "swing1979@gmail.com"
  spec.homepage = "http://github.com/xli/dtr/tree/master"
  spec.rubyforge_project = "dtr"
end