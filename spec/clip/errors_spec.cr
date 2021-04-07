require "./spec_helper"

describe "Clip::Errors::MissingCommand" do
  it "formats the error message" do
    Clip::MissingCommand.new.to_s.should eq("Error: you need to provide a command.")
  end
end

describe "Clip::Errors::UnknownCommand" do
  it "exposes the command" do
    Clip::UnknownCommand.new("command").command.should eq("command")
  end

  it "formats the error message" do
    Clip::UnknownCommand.new("command").to_s.should eq("Error: no such command command.")
  end
end
