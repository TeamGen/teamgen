require 'erb'
require 'ostruct'

class Readme
  def initialize(name:, to_run:)
    @context = {
      name: name,
      to_run: to_run,
    }
    @file_name = "README.md"
  end

  def template
%{# <%= name %>

## To Run
```
<%= to_run.join("\n") %>
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
