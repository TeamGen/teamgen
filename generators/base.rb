class Base
  def initialize(config)
    @config = config
  end

  def valid_options
    raise NotImplementedError, '#vaild_options must be implemented by subclass'
  end

  def generate
    raise NotImplementedError, '#vaild_options must be implemented by subclass'
  end
end
