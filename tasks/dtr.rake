$: << File.dirname(__FILE__) + "/../lib"

require 'dtr'
require 'dtr/raketasks'

ENV['DTR_AGENT_ENV_SETUP_CMD'] = 'mkdir log;mkdir tmp;cp ./config/database.yml.dtr ./config/database.yml;rake db:migrate; rake db:test:prepare'

def all_broadcast_addrs
  ifconfig = %x[ifconfig -a]
  ifconfig.scan(/broadcast\s(\d+\.\d+\.\d+\.\d+)/).flatten.uniq
end

DTR.broadcast_list = all_broadcast_addrs

namespace :dtr do
  
  desc 'running tests within dtr grid, use P to specify local machine runner size, default is 0'
  DTR::TestTask.new(:test) do |t|
   t.libs << "test"
   t.test_files = FileList['test/unit/**/*test.rb', 'test/functional/**/*test.rb']
   t.processes = ENV['P'] || 0
   t.verbose = false
   t.package_files.include("**/*")
   t.package_files.exclude("tmp/**/*")
   t.package_files.exclude("log/*")
  end
  
  desc 'monitoring server and agents communication'
  task(:monitor) do |t|
    DTR.monitor
  end
  
end

task :dtr_repackage => ['dtr:dtr_repackage']
task :dtr_clobber_package => ['dtr:dtr_clobber_package']
