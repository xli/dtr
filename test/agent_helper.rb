require 'fileutils'
module DTR
  module AgentHelper
    GROUP = 'dtr acceptance tests'
    def start_agents(size = 3)
      @agents_dir = File.join(Dir.pwd, 'agents')
      @agents = []
      @agents << start_agent_at(File.join(@agents_dir, 'agent1'), size)
      # @agents << start_agent_at(File.join(@agents_dir, 'agent2'), 1)
    end

    def start_agent_at(agent_dir, size, clean_dir=true)
      FileUtils.rm_rf(agent_dir) if clean_dir
      FileUtils.mkdir_p(agent_dir)
      runner_names = []
      size.times {|i| runner_names << "runner#{i}"}
      Process.fork do
        Dir.chdir(agent_dir) do
          DTR.configuration.group = GROUP
          DTR.configuration.agent_runners = runner_names
          DTR.start_agent
        end
      end
    end

    def stop_agents
      if @agents
        @agents.each do |agent|
          DTR.kill_process agent
        end
        Process.waitall
        sleep 1
      end
    ensure
      FileUtils.rm_rf(@agents_dir) rescue nil
    end
  end
end