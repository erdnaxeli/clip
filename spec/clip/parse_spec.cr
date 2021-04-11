require "./spec_helper"

struct CommandParse
  include Clip::Mapper

  getter value = 1
  getter name : String
end

describe Clip::Parse do
  describe "#parse" do
    it "accepts a string" do
      command = CommandParse.parse("--value 2 Alice")

      command.class.should eq(CommandParse)
      command = command.as(CommandParse)
      command.value.should eq(2)
      command.name.should eq("Alice")
    end
  end
end
