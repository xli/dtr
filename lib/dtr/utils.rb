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

require 'pstore'
require 'logger'
require 'timeout'

unless defined?(DTROPTIONS)
  DTROPTIONS = {}
end

module DTR
  
  def logger
    return DTROPTIONS[:logger] if DTROPTIONS[:logger]
    DTROPTIONS[:logger] = if DTROPTIONS[:log_level] == Logger::DEBUG
      Logger.new(STDOUT)
    else
      DTROPTIONS[:log_file] ||= 'dtr.log'
      dir = File.exist?('log') ? 'log' : '/tmp'
      log_file = File.join(dir,  DTROPTIONS[:log_file])
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
      puts "log: #{message}"
      message
    end
  end
  
  def silent?
    logger.level == Logger::ERROR
  end
  
  def with_monitor
    yield
  rescue Exception => e
    info {"stopping by Exception => #{e.class.name}, message => #{e.message}"}
    raise e
  end
  
  module_function :debug, :info, :error, :output, :with_monitor, :logger, :silent?, :do_print
  
  class CmdInterrupt < StandardError; end

  class Cmd
    def self.execute(cmd)
      return true if cmd.nil? || cmd.empty?
      DTR.info {"Executing: #{cmd.inspect}"}
      output = %x[#{cmd} 2>&1]
      DTR.info {"Execution is done, status: #{$?.exitstatus}"}
      DTR.error {"#{cmd.inspect} output:\n#{output}"} if $?.exitstatus != 0
      $?.exitstatus == 0
    end
  end
  
  class EnvStore

    FILE_NAME = '.dtr_env_pstore' unless defined?(FILE_NAME)

    def self.destroy
      File.delete(FILE_NAME) if File.exist?(FILE_NAME)
    end

    def [](key)
      return nil unless File.exist?(FILE_NAME)
      
      repository = PStore.new(FILE_NAME)
      repository.transaction(true) do
        repository[key]
      end
    end

    def []=(key, value)
      repository = PStore.new(FILE_NAME)
      repository.transaction do
        repository[key] = value
      end
    end
    
    def <<(key_value)
      key, value = key_value
      repository = PStore.new(FILE_NAME)
      repository.transaction do
        repository[key] = (repository[key] || []) << value
      end
    end
    
    def shift(key)
      repository = PStore.new(FILE_NAME)
      repository.transaction do
        if array = repository[key]
          array.shift
          repository[key] = array
        end
      end
    end
  end

end
