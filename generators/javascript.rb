require_relative 'base'
require_relative 'files/readme'

class Javascript < Base
  def initialize(*)
    super
    @entry = 'index.js'
    @version = 'latest'
    @commands = [
    ]
  end

  def valid_options
    {}
  end

  def generate_entry_point
    path = "#{@directory}/#{@entry}"
    return if File.file?(path)
    File.open(path.to_s, 'w') do |f|
      f.write("console.log('Hello World')\n")
    end
  end

  def generate_dockerfile
    path = "#{@directory}/Dockerfile"
    return if File.file?(path)
    File.open(path.to_s, 'w') do |f|
      f.write("FROM node:#{@version}\n")
    end
  end

  def generate_readme
    readme = Readme.new(
      name: @config['name'],
      to_run: [
        "docker build -t #{@config['name']} .",
        "docker run -it --rm --name my-running-script -v \"$PWD\":/usr/src/myapp -w /usr/src/myapp node:#{@version} node #{@entry}"
      ]
    )
    readme.save(@directory)
  end

  def generate_package_json
    @commands.push('node npm init -y -f')
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
    generate_package_json
    generate_readme
    run_commands
  end
end
