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

  def parse(command : String)
    parse(Process.parse_arguments(command))
  end
end
