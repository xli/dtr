class LoggerStub
  def initialize
    @store = DTR::EnvStore.new
    clear
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
    message = block_given? ? block.call : msg.to_s
    @store << [:logs, [level, message]]
  end

  def logs
    @store[:logs]
  end

  def clear
    @store[:logs] = []
  end
end
