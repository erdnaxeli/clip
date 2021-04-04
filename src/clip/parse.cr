module Clip::Parse
  def parse(command : Array(String) = ARGV) : self | Clip::Mapper::Help
    if command.includes?("--help")
      Clip::Mapper::Help::INSTANCE
    else
      new command
    end
  end
end