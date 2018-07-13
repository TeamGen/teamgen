require_relative 'base'

class Docker < Base
  def initialize(docker_commands:)
    @context = {
      docker_commands: docker_commands
    }
    @file_name = "Dockerfile"
  end

  def template
%{<%= docker_commands.join("\n") %>
}
  end

  def save(directory)
    path = "#{directory}/#{@file_name}"
    return if File.file?(path)
    File.open(path, 'w') do |f|
      f.write(render)
    end
  end
end
