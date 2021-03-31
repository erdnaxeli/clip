require "./spec_helper"

abstract struct Commands
  include Clip::Mapper

  Clip.add_commands(
    {
      "add": AddCommand,
      "rm":  RemoveCommand,
    }
  )
end

@[Clip::Doc("Add a file.")]
struct AddCommand < Commands
  include Clip::Mapper

  getter file : String
end

@[Clip::Doc("Remove a file.")]
struct RemoveCommand < Commands
  include Clip::Mapper

  @[Clip::Doc("Do not actually remove the file from the disk.")]
  getter cached = false
  getter file : String
end

abstract struct CommandsAndOption
  include Clip::Mapper

  Clip.add_commands(
    {
      "add" => AddCommandAO,
      "rm"  => RemoveCommandAO,
    }
  )

  getter verbose = false
end

@[Clip::Doc("Add a file.")]
struct AddCommandAO < CommandsAndOption
  include Clip::Mapper

  getter file : String
end

@[Clip::Doc("Remove a file.")]
struct RemoveCommandAO < CommandsAndOption
  include Clip::Mapper

  @[Clip::Doc("Do not actually remove the file from the disk.")]
  getter cached = false
  getter file : String
end

describe "Clip" do
  describe ".add_commands" do
    it "adds commands to the help" do
      Commands.help("bin").should eq(
        "Usage: bin COMMAND [ARGS]...

Commands:
  add  Add a file.
  rm   Remove a file.
"
      )
    end

    it "parses a command" do
      cmd = Commands.new(["rm", "--cached", "somefile"])

      cmd.class.should eq(RemoveCommand)
      cmd = cmd.as(RemoveCommand)
      cmd.cached.should be_true
      cmd.file.should eq("somefile")
    end
  end
end
