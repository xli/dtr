# Copyright (c) 2007-2008 Li Xiao <iam@li-xiao.com>
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

module DTR
  module Agent
    module RailsExt
      module DatabaseInitializer
        def initialize_database
          dtr_database_config_exists = File.exist?('./config/database.yml.dtr')
          default_database_config_exists = File.exist?('./config/database.yml')

          if !dtr_database_config_exists && !default_database_config_exists
            DTR.info("No ./config/database.yml.dtr and ./config/database.yml exists, bypass database initialization.")
            return
          end

          if dtr_database_config_exists
            DTR.info("Found ./config/database.yml.dtr, use it as database configuration")
            FileUtils.cp('./config/database.yml.dtr', './config/database.yml')
          end

          env = "DTR_RUNNER_NAME=#{ENV['DTR_RUNNER_NAME']}"
          # Counldn't add --trace here, for some machine failed db:test:prepare by Test::Unit detected --trace is a invalid option
          unless Cmd.execute("rake db:migrate:reset db:test:prepare #{env}")
            raise 'Initialize database failed!'
          end
        end
      end

      module WorkingEnvExt
        include DatabaseInitializer

        def self.included(base)
          base.alias_method_chain :setup_environment, :preparing_database
        end

        def setup_environment_with_preparing_database
          if setup_environment_command.blank?
            DTR.debug("No setup environment command found, try database initialization")
            initialize_database
          end
          setup_environment_without_preparing_database
        end
      end
    end
  end
end
