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

require 'logger'
require 'fileutils'

module DTR
  module LoggerExt
    DATETIME_FORMAT = "%m-%d %H:%M:%S"
    def logger(file=nil)
      @logger ||= create_default_logger(file)
    end

    def logger=(logger)
      @logger = logger
    end

    def create_default_logger(file)
      dir = 'log'
      FileUtils.mkdir_p(dir)
      log_file = File.join(dir,  file || 'dtr.log')
      do_println "DTR logfile at #{Dir.pwd}/#{log_file}"
      logger = Logger.new(log_file, 1, 5*1024*1024)
      logger.datetime_format = DATETIME_FORMAT
      logger.level = (ENV['DTR_LOG_LEVEL'] || Logger::INFO).to_i
      logger
    end

    def do_print(str)
      unless ENV['DTR_ENV'] == 'test'
        print str
      end
    end

    def do_println(str)
      do_print("#{str}\n")
    end

    def debug(message=nil, &block)
      output(:debug, message, &block)
    end

    def info(message=nil, &block)
      output(:info, message, &block)
    end

    def error(message=nil, &block)
      output(:error, message, &block)
    end

    def output(level, msg=nil, &block)
      logger.send(level) do
        message = block_given? ? block.call : msg.to_s
        # puts "log: #{message}"

        #output message when it's an error for agent error log should be displayed in console
        if level == :error
          $stderr.puts ''
          $stderr.puts "[#{Time.now.strftime(DATETIME_FORMAT)}] ERROR: #{message}"
        end
        message
      end
    end
  end

  extend LoggerExt
end
