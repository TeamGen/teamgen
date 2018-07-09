require 'optparse'
require 'yaml'
require_relative 'services/base'

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: teamgen.rb [options] [<directory>]"

  options[:config] = 'teamgen.yml'
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

valid_services = []

config['services'].each do |s|
  service = Services::Base.new(s)
  if service.error.length > 0
    p "1"
    p service.error
    exit(-1)
  end

  unless service.valid?
    p "2"
    p service.error
    exit(-1)
  end

  valid_services.push(service)
end

valid_services.each do |service|
  service.generate
end
