module Clip::Parse
  def parse(command : Array(String) = ARGV)
    {% begin %}
      if command.includes?("--help")
        {{@type}}::Help::INSTANCE
      else
        new command
      end
    {% end %}
  end
end
