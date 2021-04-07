module Clip::Parse
  def parse(command : Array(String) = ARGV, path = Array(String).new)
    {% begin %}
      if command.includes?("--help")
        {{@type}}::Help.new(path)
      else
        new command, path
      end
    {% end %}
  end
end
