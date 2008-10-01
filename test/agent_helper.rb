
module DTR
  module AgentHelper
    def start_agents(size=3)
      runner_names = []
      size.times {|i| runner_names << "runner#{i}"}
      @agents = Process.fork do
        begin
          DTR.launch_agent(runner_names, nil)
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
    end
  end
end