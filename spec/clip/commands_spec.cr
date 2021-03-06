require "./spec_helper"

@[Clip::Doc("Some command.")]
abstract struct Commands
  include Clip::Mapper

  Clip.add_commands(
    {
      "add":    AddCommand,
      "remove": RemoveCommand,
    }
  )
end

@[Clip::Doc("Add a file.")]
abstract struct AddCommand < Commands
  include Clip::Mapper

  Clip.add_commands({"again" => AgainCommand})
end

@[Clip::Doc("Remove a file.")]
struct RemoveCommand < Commands
  include Clip::Mapper

  @[Clip::Doc("Do not actually remove the file from the disk.")]
  getter cached = false
  getter file : String
end

struct AgainCommand < AddCommand
  include Clip::Mapper

  getter file : String
end

describe "Clip" do
  describe ".add_commands" do
    describe "#help" do
      it "adds commands to the help" do
        Commands.help("bin").should eq(
          "Usage: bin COMMAND [ARGS]...

Some command.

Commands:
  add     Add a file.
  remove  Remove a file.
  help    Show this message and exit.
"
        )
      end

      it "defaults to PROGRAM_NAME for command name" do
        Commands.help.should eq(
          "Usage: #{PROGRAM_NAME} COMMAND [ARGS]...

Some command.

Commands:
  add     Add a file.
  remove  Remove a file.
  help    Show this message and exit.
"
        )
      end

      it "accepts nil for command name" do
        Commands.help(nil).should eq(
          "Usage: COMMAND [ARGS]...

Some command.

Commands:
  add     Add a file.
  remove  Remove a file.
  help    Show this message and exit.
"
        )
      end
    end

    describe "#parse" do
      it "raises an error when no command is provided" do
        expect_raises(Clip::MissingCommand) do
          Commands.parse(Array(String).new)
        end
      end

      it "parses a command" do
        cmd = Commands.parse(["remove", "--cached", "somefile"])

        cmd.class.should eq(RemoveCommand)
        cmd = cmd.as(RemoveCommand)
        cmd.cached.should be_true
        cmd.file.should eq("somefile")
      end

      it "handles the help command" do
        cmd = Commands.parse(["help"])

        cmd = cmd.as(Commands::Help)
        cmd.help.should eq(Commands.help)
      end

      it "handles the help option" do
        cmd = Commands.parse(["--help"])

        cmd = cmd.as(Commands::Help)
        cmd.help.should eq(Commands.help)
      end

      it "handles commands' help" do
        cmd = Commands.parse(["remove", "--help"])

        cmd = cmd.as(RemoveCommand::Help)
        cmd.help("bin").should eq(RemoveCommand.help("bin remove"))
      end

      it "handles recursive commands' help" do
        cmd = Commands.parse(["add", "again", "--help"])

        cmd = cmd.as(AgainCommand::Help)
        cmd.help("bin").should eq(AgainCommand.help("bin add again"))
      end
    end
  end
end
