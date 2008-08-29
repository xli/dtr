Gem::Specification.new do |s|
  
  #### Basic information.

  s.name = 'dtr'
  s.version = "0.0.4"
  s.summary = "DTR is a distributed test runner to run tests on distributed computers for decreasing build time."

  #### Dependencies and requirements.

  s.add_dependency('daemons', '> 1.0.7')
  #s.requirements << ""

  #### Which files are to be included in this gem?  Everything!  (Except SVN directories.)

  PKG_FILES = FileList[
    'install.rb',
    '[A-Z]*',
    'bin/**/*', 
    'lib/**/*.rb', 
    'lib/**/*.rake', 
    'test/**/*.rb',
    'doc/**/*'
  ]
  PKG_FILES.exclude('doc/example/*.o')
  PKG_FILES.exclude(%r{doc/example/main$})
  s.files = PKG_FILES.to_a.delete_if {|item| item.include?(".git")}

  #### Load-time details: library and application (you will need one or both).

  s.require_path = 'lib'                         # Use these for libraries.

  s.bindir = "bin"                               # Use these for applications.
  s.executables = ["dtr"]
  s.default_executable = "dtr"

  #### Documentation and testing.

  s.has_rdoc = true
  s.extra_rdoc_files = rd.rdoc_files.reject { |fn| fn =~ /\.rb$/ }.to_a
  s.rdoc_options = rd.options

  #### Author and project details.

  s.author = "Li Xiao"
  s.email = "swing1979@gmail.com"
  s.homepage = "http://github.com/xli/dtr/tree/master"
  s.rubyforge_project = "dtr"
end