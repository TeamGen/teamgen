class Base
  def initialize(config, directory)
    @config = config
    @directory = directory
    @usage_commands = []
  end

  def valid_options
    raise NotImplementedError, '#vaild_options must be implemented by subclass'
  end

  def generate_readme
    readme = Readme.new(
      name: @config['name'],
      usage_commands: @usage_commands
    )
    readme.save(@directory)
  end

  def generate
    raise NotImplementedError, '#vaild_options must be implemented by subclass'
  end
end
