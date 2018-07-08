require 'optparse'
require 'yaml'

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: teamgen.rb [options] [<directory>]"

  options[:config] = 'teamgen.yaml'
  opts.on( '-c', '--config FILE', 'Specify a configuration file.' ) do |file|
    options[:config] = file
  end

  opts.on( '-h', '--help', 'Print this help message' ) do
    puts opts
    exit
  end
end

optparse.parse!

# directory = if ARGV.empty?
#               "./"
#             elsif ARGV.length == 1
#               ARGV.first
#             else
#               puts optparse
#               exit(-1)
#             end

config = YAML.load_file(options[:config])
p config

config['services'].each do |service|
  directory = service['name']
  Dir.mkdir(directory)

  entry = ""
  if service['framework'] == nil
    entry = 'main.rb'
    File.open("#{directory}/#{entry}", 'w') do |f|
      f.write("puts 'Hello World'\n")
    end
  else
    puts "unsupported keyword framework"
    exit(-1)
  end

  if service['language'] === 'ruby'
    File.open("#{directory}/Dockerfile", 'w') do |f|
      f.write("FROM ruby:2.5\n")
      f.write("RUN bundle config --global frozen 1\n")
      f.write("WORKDIR /usr/src/app\n")
      f.write("COPY Gemfile Gemfile.lock ./\n")
      f.write("RUN bundle install\n")
      f.write("COPY . .\n")
      f.write("CMD ['./#{entry}']\n")
    end

    File.open("#{directory}/README.md", "w") do |f|
      f.write("# #{service['name']}\n")
      f.write("\n")
      f.write("## To Run\n")
      f.write("```\n")
      f.write("docker build -t #{service['name']} .\n")
      f.write("docker run -it --rm --name my-running-script -v \"$PWD\":/usr/src/myapp -w /usr/src/myapp ruby:2.5 ruby #{entry}\n")
      f.write("```\n")
    end

    File.open("#{directory}/Gemfile", "w") do |f|
    end

    `cd #{directory} && docker run --rm -v "$PWD":/usr/src/app -w /usr/src/app ruby:2.5 bundle install`
  else
    puts "unsupported language #{service['language']}"
    exit(-1)
  end
end
