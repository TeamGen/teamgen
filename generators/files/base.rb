require 'erb'
require 'ostruct'

class Base
  def template
    raise NotImplementedError, '#vaild_options must be implemented by subclass'
  end

  def render
    ERB.new(template).result(OpenStruct.new(@context).instance_eval { binding })
  end

  def save(path)
    raise NotImplementedError, '#vaild_options must be implemented by subclass'
  end
end
