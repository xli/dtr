# Copyright (c) 2007-2008 Li Xiao
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'singleton'

module DTR
  module TestUnit
    class WorkerClub
      include Singleton

      DEFAULT_RUN_TEST_TIMEOUT = 60 #seconds

      def start_thread(drb_runner, remote_runner)
        thread = Thread.start(drb_runner, remote_runner) do |local, remote|
          local.run_test_on(remote, timeout)
        end
        thread[:started_on] = Time.now
        workers.add(thread)
      end

      # Performs a wait on all the currently running threads and kills any that take
      # too long. It waits by ENV['RUN_TEST_TIMEOUT'] || 60 seconds
      def graceful_shutdown
        while reap_dead_workers("shutdown") > 0
          DTR.info "Waiting for #{workers.list.length} threads to finish, could take #{timeout} seconds."
          sleep timeout / 60
        end
      end

      def timeout
        ENV['RUN_TEST_TIMEOUT'] || DEFAULT_RUN_TEST_TIMEOUT
      end

      private
      def workers
        @workers ||= ThreadGroup.new
      end

      # Used internally to kill off any worker threads that have taken too long
      # to complete processing. It returns the count of workers still active
      # after the reap is done. It only runs if there are workers to reap.
      def reap_dead_workers(reason='unknown')
        if workers.list.length > 0
          DTR.info "Reaping #{workers.list.length} threads because of '#{reason}'"
          error_msg = "#{Time.now}: WorkerClub timed out this thread: #{reason}"
          mark = Time.now
          workers.list.each do |worker|
            worker[:started_on] = Time.now if not worker[:started_on]

            if mark - worker[:started_on] > timeout
              DTR.info "Thread #{worker.inspect} is too old, killing."
              worker.raise(TimeoutError.new(error_msg))
            end
          end
        end

        return workers.list.length
      end
    end
  end
end