require_relative 'errors'
require_relative 'generators/ruby'

# Service generator
class Service
  VALID_LANGUAGES = ['ruby'].freeze
  attr_reader :error

  def initialize(config)
    @config = config
    @error = ''
    @generator = case language
                 when 'ruby'
                   Ruby.new(config)
                 else
                   raise ConfigError, "unsupported language #{language}"
                 end
    validate
  end

  def generate
    @generator.generate
  end

  private

  def language
    unless @config['language']
      raise ConfigError, "language missing from config #{@config}"
    end
    unless VALID_LANGUAGES.include? @config['language']
      raise ConfigError, "unsupported language #{@config['language']}"
    end
    @config['language']
  end

  def validate_name
    return if @config['name']
    raise ConfigError, 'missing service name'
  end

  def validate_linter
    return unless @config['linter']
    raise ConfigError, 'missing linter name' unless @config['linter']['name']
    valid_linter = @generator.valid_options['linter']['name'].include? @config['linter']['name']
    raise ConfigError, "unsupported linter #{@config['linter']['name']}" unless valid_linter
  end

  def validate_tests
    return unless @config['tests']
    valid_tests = @generator.valid_options['tests'].include? @config['tests']
    raise ConfigError, "unsupported tests #{@config['tests']}" unless valid_tests
  end

  def validate
    validate_name
    validate_linter
    validate_tests
  end
end
