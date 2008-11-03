require 'fileutils'
module DTR
  module AgentHelper
    include Adapter::Master
    GROUP = 'dtr_acceptance_tests'
    def start_agents(options={})
      options = {:size => 3, :clean_dir => true}.merge(options)
      @agents_dir = File.join(Dir.pwd, 'agents')
      start_agent_at(agent1_dir, options)
    end

    def agent1_dir
      File.join(@agents_dir, 'agent1')
    end

    def agent1_runner1_dir
      File.join(agent1_dir, Socket.gethostname.gsub(/[^\d\w]/, '_'), 'tance_rails_ext_test', 'runner1')
    end

    def start_agent_at(agent_dir, options={})
      FileUtils.rm_rf(agent_dir) if options[:clean_dir]
      FileUtils.mkdir_p(agent_dir)
      runner_names = []
      options[:size].times {|i| runner_names << "runner#{i}"}
      Process.fork do
        Dir.chdir(agent_dir) do
          DTR.configuration.refresh
          DTR.configuration.master_heartbeat_interval = options[:master_heartbeat_interval] || 2
          DTR.configuration.follower_listen_heartbeat_timeout = options[:follower_listen_heartbeat_timeout] || 3
          DTR.configuration.group = GROUP
          DTR.configuration.agent_runners = runner_names
          DTR.configuration.save
        end
      end
      Thread.start do
        DTR.run_script("Dir.chdir(#{agent_dir.inspect}) { DTR::Agent.start(:hypnotize) }")
      end
    end

    def stop_agents
      group_agents_should_die(GROUP)
      Process.waitall
      sleep 1
    ensure
      FileUtils.rm_rf(@agents_dir) rescue nil
    end
  end
end