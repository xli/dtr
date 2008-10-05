require 'fileutils'
module DTR
  module AgentHelper
    def start_agents
      @agents_dir = File.join(Dir.pwd, 'agents')
      @agents = []
      @agents << start_agent_at(File.join(@agents_dir, 'agent1'), 1)
      @agents << start_agent_at(File.join(@agents_dir, 'agent2'), 2)
    end

    def start_agent_at(agent_dir, size)
      FileUtils.rm_rf(agent_dir)
      FileUtils.mkdir_p(agent_dir)
      runner_names = []
      size.times {|i| runner_names << "runner#{i}"}
      Process.fork do
        begin
          Dir.chdir(agent_dir) do
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
        @agents.each do |agent|
          Process.kill 'TERM', agent rescue nil
        end
        Process.waitall
      end
    ensure
      FileUtils.rm_rf(@agents_dir) rescue nil
    end
  end
end