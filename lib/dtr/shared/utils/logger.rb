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

require 'logger'

module DTR
  
  def logger
    return DTROPTIONS[:logger] if DTROPTIONS[:logger]
    DTROPTIONS[:logger] = if DTROPTIONS[:log_level] == Logger::DEBUG
      Logger.new(STDOUT)
    else
      DTROPTIONS[:log_file] ||= 'dtr.log'
      dir = File.exist?('log') ? 'log' : '/tmp'
      log_file = File.join(dir,  DTROPTIONS[:log_file])
      do_print "logfile at #{log_file}\n"
      Logger.new(log_file, 1, 5*1024*1024)
    end
    DTROPTIONS[:logger].datetime_format = "%m-%d %H:%M:%S"
    DTROPTIONS[:logger].level = DTROPTIONS[:log_level] || Logger::INFO
    DTROPTIONS[:logger]
  end
  
  def do_print(str)
    unless ENV['DTR_ENV'] == 'test'
      print str
    end
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
        $stderr.puts message
      end
      message
    end
  end
  
  module_function :debug, :info, :error, :output, :logger, :do_print
  
end
