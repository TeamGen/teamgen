module Services
  VALID_LANGUAGES = ['ruby'].freeze
  class Base
    def initialize(config)
      @config = config
      @error = ""

      unless @config['language']
        @error = "missing service language"
        return false
      end

      unless VALID_LANGUAGES.include? @config['language']
        @error = "unsupported language #{@config['language']}"
        return false
      end
    end

    def error
      @error
    end

    def generate
      directory = @config['name']
      Dir.mkdir(directory)

      case @config['language']
      when 'ruby'
        version = '2.5'
        entry = 'main.rb'

        File.open("#{directory}/#{entry}", 'w') do |f|
          f.write("puts 'Hello World'\n")
        end

        File.open("#{directory}/Dockerfile", 'w') do |f|
          f.write("FROM ruby:#{version}\n")
          f.write("RUN bundle config --global frozen 1\n")
          f.write("WORKDIR /usr/src/app\n")
          f.write("COPY Gemfile Gemfile.lock ./\n")
          f.write("RUN bundle install\n")
          f.write("COPY . .\n")
          f.write("CMD ['./#{entry}']\n")
        end

        File.open("#{directory}/README.md", "w") do |f|
          f.write("# #{@config['name']}\n")
          f.write("\n")
          f.write("## To Run\n")
          f.write("```\n")
          f.write("docker build -t #{@config['name']} .\n")
          f.write("docker run -it --rm --name my-running-script -v \"$PWD\":/usr/src/myapp -w /usr/src/myapp ruby:#{version} ruby #{entry}\n")
          f.write("```\n")
        end

        File.open("#{directory}/Gemfile", "w") do |f|
        end

        commands = [
          'ruby:2.5 bundle install'
        ]

        if @config['linter']
          if @config['linter']['name'] === 'rubocop'
            commands.push('bundle add rubocop --group=development')
            File.open("#{directory}/.rubocop.yml", "w") do |f|
              f.write("AllCops:\n")
              f.write("  TargetRubyVersion: #{version}\n")
            end
          end
        end

        if @config['tests'] === 'rspec'
          commands.push('bundle add rspec --group=test')
          commands.push('rspec --init')
        end

        commands = commands.join(' && ')
        `cd #{directory} && docker run --rm -v "$PWD":/usr/src/app -w /usr/src/app #{commands}`
      else
        throw "unsupported language #{@config['language']}"
      end
    end

    def vaild_options
      # TODO: move to subclass
      {
        'linter' => {
          'name' => ['rubocop'],
        },
        'tests' => ['rspec']
      }
      # fail NotImplementedError, '#vaild_options must be implemented by subclass'
    end

    def valid?
      unless @config['name']
        @error = "missing service name"
        return false
      end

      if @config['linter']
        unless @config['linter']['name']
          @error = "missing linter name"
          return false
        end

        unless vaild_options['linter']['name'].include? @config['linter']['name']
          @error = "unsupported linter #{@config['linter']['name']}"
          return false
        end
      end

      if @config['tests']
        unless vaild_options['tests'].include? @config['tests']
          @error = "unsupported tests #{@config['tests']}"
          return false
        end
      end
      true
    end
  end
end
