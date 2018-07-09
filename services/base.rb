module Services
  class Base
    def initialize(config)
      @config = config
      @error = ""
      @vaild_options = {
        'ruby' => {
          'linter' => {
            'name' => ['rubocop'],
          },
          'tests' => ['rspec']
        }
      }
    end

    def error
      @error
    end

    def valid?
      unless @config['name']
        @error = "missing service name"
        return false
      end

      unless @config['language']
        @error = "missing service language"
        return false
      end

      unless @vaild_options.has_key? @config['language']
        @error = "unsupported language #{@config['language']}"
        return false
      end

      options = @vaild_options[@config['language']]

      if @config['linter']
        unless @config['linter']['name']
          @error = "missing linter name"
          return false
        end

        unless options['linter']['name'].include? @config['linter']['name']
          @error = "unsupported linter #{@config['linter']['name']}"
          return false
        end
      end

      if @config['tests']
        unless options['tests'].include? @config['tests']
          @error = "unsupported tests #{@config['tests']}"
          return false
        end
      end
      true
    end
  end
end
