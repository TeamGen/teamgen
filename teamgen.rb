require 'optparse'
require 'yaml'
require_relative 'service'
require_relative 'errors'

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = 'Usage: teamgen.rb [options] [<directory>]'

  options[:config] = 'teamgen.yml'
  opts.on('-c', '--config FILE', 'Specify a configuration file.') do |file|
    options[:config] = file
  end

  opts.on('-h', '--help', 'Print this help message') do
    puts opts
    exit
  end
end

optparse.parse!

directory = if ARGV.empty?
              './'
            elsif ARGV.length == 1
              ARGV.first
            else
              puts optparse
              exit(-1)
            end

config = YAML.load_file(options[:config])

valid_services = []

config['services'].each do |s|
  service = nil
  begin
    service = Service.new(s, directory)
  rescue ConfigError => error
    p error.message
    exit(-1)
  end
  valid_services.push(service)
end

valid_services.each(&:generate)
