require_relative 'base'
require_relative 'files/docker'

class Ruby < Base
  def initialize(*)
    super
    @version = '2.5'
    @entry = 'main.rb'
    @commands = [
      "ruby:#{@version} bundle install"
    ]
  end

  def valid_options
    {
      'linter' => {
        'name' => ['rubocop']
      },
      'tests' => ['rspec']
    }
  end

  def generate_entry_point
    path = "#{@directory}/#{@entry}"
    return if File.file?(path)
    File.open(path.to_s, 'w') do |f|
      f.write("puts 'Hello World'\n")
    end
  end

  def generate_dockerfile
    docker = Docker.new(
      docker_commands: [
        "FROM ruby:#{@version}",
        "RUN bundle config --global frozen 1",
        "WORKDIR /usr/src/app",
        "COPY Gemfile Gemfile.lock ./",
        "RUN bundle install",
        "COPY . .",
        "CMD ['./#{@entry}']"
      ]
    )
    docker.save(@directory)

    @usage_commands = [
      "docker build -t #{@config['name']} .",
      "docker run -it --rm --name my-running-script -v \"$PWD\":/usr/src/myapp -w /usr/src/myapp ruby:#{@version} ruby #{@entry}"
    ]
  end

  def generate_gemfile
    path = "#{@directory}/Gemfile"
    return if File.file?(path)
    File.open(path.to_s, 'w') do |f|
    end
  end

  def generate_linter
    return unless @config['linter']
    if @config['linter']['name'] == 'rubocop'
      @commands.push('bundle add rubocop --group=development')
      path = "#{@directory}/.rubocop.yml"
      return if File.file?(path)
      File.open(path.to_s, 'w') do |f|
        f.write("AllCops:\n")
        f.write("  TargetRubyVersion: #{@version}\n")
      end
    end
  end

  def generate_tests
    if @config['tests'] == 'rspec'
      @commands.push('bundle add rspec --group=test')
      @commands.push('rspec --init')
    end
  end

  def run_commands
    return unless @commands.any?
    # TODO don't add/run commands if they have already been run
    @commands = @commands.join(' && ')
    `cd #{@directory} && docker run --rm -v "$PWD":/usr/src/app -w /usr/src/app #{@commands}`
  end

  def generate
    generate_entry_point
    generate_dockerfile
    generate_readme
    generate_gemfile
    generate_linter
    generate_tests
    run_commands
  end
end
