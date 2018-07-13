require 'erb'
require 'ostruct'

class Readme
  def initialize(name:, usage_commands:)
    @context = {
      name: name,
      usage_commands: usage_commands,
    }
    @file_name = "README.md"
  end

  def template
%{# <%= name %>

## Usage
```
<%= usage_commands.join("\n") %>
```
}
  end

  def render
    ERB.new(template).result(OpenStruct.new(@context).instance_eval { binding })
  end

  def save(directory)
    path = "#{directory}/#{@file_name}"
    return if File.file?(path)
    File.open(path, 'w') do |f|
      f.write(render)
    end
  end
end
