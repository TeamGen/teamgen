require 'fileutils'
require_relative 'errors'
require_relative 'generators/ruby'
require_relative 'generators/javascript'

# Service generator
class Service
  VALID_LANGUAGES = ['ruby', 'javascript'].freeze
  attr_reader :error

  def initialize(config, directory)
    @config = config
    @directory = directory
    @language = @config['language'] if valid_language?
    @generator = generator

    valid_name?
    valid_linter?
    valid_tests?
  end

  def generate
    FileUtils.mkdir_p(@directory) unless File.directory?(@directory)
    @generator.generate
  end

  private

  def generator
    case @language
    when 'ruby'
      Ruby.new(@config, @directory)
    when 'javascript'
      Javascript.new(@config, @directory)
    else
      raise ConfigError, "unsupported language #{@language}"
    end
  end

  def valid_language?
    unless @config['language']
      raise ConfigError, "language missing from config #{@config}"
    end
    unless VALID_LANGUAGES.include? @config['language']
      raise ConfigError, "unsupported language #{@config['language']}"
    end
    true
  end

  def valid_name?
    return true if @config['name']
    raise ConfigError, 'missing service name'
  end

  def valid_linter?
    return unless @config['linter']
    raise ConfigError, 'missing linter name' unless @config['linter']['name']
    valid_linter = @generator.valid_options['linter']['name'].include? @config['linter']['name']
    raise ConfigError, "unsupported linter #{@config['linter']['name']}" unless valid_linter
    true
  end

  def valid_tests?
    return unless @config['tests']
    valid_tests = @generator.valid_options['tests'].include? @config['tests']
    raise ConfigError, "unsupported tests #{@config['tests']}" unless valid_tests
    true
  end
end
