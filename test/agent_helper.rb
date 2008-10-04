require 'fileutils'
module DTR
  module AgentHelper
    def start_agents(size=3)
      @agents_dir = File.join(Dir.pwd, 'agents')
      FileUtils.rm_rf(@agents_dir)
      Dir.mkdir(@agents_dir)
      runner_names = []
      size.times {|i| runner_names << "runner#{i}"}
      @agents = Process.fork do
        begin
          Dir.chdir(@agents_dir) do
            DTR.launch_agent(runner_names, nil)
          end
        rescue Exception => e
          puts e.message
          puts e.backtrace.join("\n")
        end
      end
    end
    
    def stop_agents
      if @agents
        Process.kill 'TERM', @agents rescue nil
      end
      Process.waitall
      puts "stop_agents: #{Dir.pwd}"
      FileUtils.rm_rf(@agents_dir)
    end
  end
end