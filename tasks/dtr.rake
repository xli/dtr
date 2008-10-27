$: << File.dirname(__FILE__) + "/../lib"

require 'dtr'
require 'dtr/raketasks'

def all_broadcast_addrs
  ifconfig = %x[ifconfig -a]
  ifconfig.scan(/broadcast\s(\d+\.\d+\.\d+\.\d+)/).flatten.uniq
end

DTR.broadcast_list = ENV['BROADCAST_IP'] ? [ENV['BROADCAST_IP']] : all_broadcast_addrs
DTR.group = ENV['DTR_GROUP'] || RAILS_ROOT.to_s.split('/').last

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
  
  desc 'Monitoring server and agents status. Used for testing your dtr grid environment. CAUTION! monitoring agents causes all idle agents hang on by the monitor process.'
  task(:monitor) do |t|
    DTR.monitor
  end
  
end

task :dtr_repackage => ['dtr:dtr_repackage']
task :dtr_clobber_package => ['dtr:dtr_clobber_package']
