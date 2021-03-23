require "./spec_helper"

struct EmptyOption
  include Clip::Mapper
end

struct FlagOption
  include Clip::Mapper

  getter flag : Bool
end

struct FlagOptions
  include Clip::Mapper

  getter flag : Bool
  getter flug : Bool
end

struct FlagDefaultTrueOption
  include Clip::Mapper

  getter flag = true
end

struct FlagDefaultFalseOption
  include Clip::Mapper

  getter flag = false
end

struct StringArgument
  include Clip::Mapper

  getter str : String
end

struct StringDefaultArgument
  include Clip::Mapper

  @[Clip::Argument]
  getter str = "somestr"
end

struct StringOption
  include Clip::Mapper

  @[Clip::Option]
  getter str : String
end

struct StringDefaultOption
  include Clip::Mapper

  getter str = "somestr"
end

struct IntArgument
  include Clip::Mapper

  getter number : Int32
end

struct IntDefaultArgument
  include Clip::Mapper

  @[Clip::Argument]
  getter number = 42
end

struct IntOption
  include Clip::Mapper

  @[Clip::Option]
  getter number : Int32
end

struct IntDefaultOption
  include Clip::Mapper

  getter number = 42
end

struct FloatOption
  include Clip::Mapper

  @[Clip::Option]
  getter number : Float32
end

struct ComplexParams
  include Clip::Mapper

  getter effect = true
  @[Clip::Option]
  getter name : String
  getter size = 4

  getter input : String
  @[Clip::Argument]
  getter output = "out"
end

describe Clip::Mapper do
  it "requires an option without default" do
    ex = expect_raises(Clip::ParsingError) do
      FlagOption.new(Array(String).new)
    end

    ex.options.should eq({"flag" => Clip::Errors::Required})
  end

  it "requires all option without default" do
    ex = expect_raises(Clip::ParsingError) do
      FlagOptions.new(Array(String).new)
    end

    ex.options.should eq(
      {
        "flag" => Clip::Errors::Required,
        "flug" => Clip::Errors::Required,
      }
    )
  end

  it "reject unknown options" do
    ex = expect_raises(Clip::ParsingError) do
      EmptyOption.new(["-f", "--name=test"])
    end

    ex.options.should eq(
      {
        "f" => Clip::Errors::Unknown,
        "name" => Clip::Errors::Unknown,
      }
    )
    ex.arguments.size.should eq(0)
  end

  it "reads a flag" do
    params = FlagOption.new(["--flag"])
    params.flag.should be_true
  end

  it "reads a no flag" do
    params = FlagOption.new(["--no-flag"])
    params.flag.should be_false
  end

  it "reads a flag with a default value true" do
    params = FlagDefaultTrueOption.new(Array(String).new)
    params.flag.should be_true
  end

  it "reads a flag with a default value false" do
    params = FlagDefaultFalseOption.new(Array(String).new)
    params.flag.should be_false
  end

  it "overwrites a flags with a default value with false" do
    params = FlagDefaultTrueOption.new(["--no-flag"])
    params.flag.should be_false
  end

  it "overwrites a flags with a default value with true" do
    params = FlagDefaultFalseOption.new(["--flag"])
    params.flag.should be_true
  end

  it "reads a string argument" do
    params = StringArgument.new(["somestr"])
    params.str.should eq("somestr")
  end

  it "reads a string argument with a default value" do
    params = StringDefaultArgument.new(Array(String).new)
    params.str.should eq("somestr")
  end

  it "overwrites a string argument with a default value" do
    params = StringDefaultArgument.new(["someothervalue"])
    params.str.should eq("someothervalue")
  end

  it "reads a string option" do
    params = StringOption.new(["--str", "somestr"])
    params.str.should eq("somestr")
  end

  it "reads a string option with a default value" do
    params = StringDefaultOption.new(Array(String).new)
    params.str.should eq("somestr")
  end

  it "overwrites a string option with a default value" do
    params = StringDefaultOption.new(["--str", "someothervalue"])
    params.str.should eq("someothervalue")
  end

  it "reads an int argument" do
    params = IntArgument.new(["42"])
    params.number.should eq(42)
  end

  it "reads an int argument with a default value" do
    params = IntDefaultArgument.new(Array(String).new)
    params.number.should eq(42)
  end

  it "overwrites an int argument with a default value" do
    params = IntDefaultArgument.new(["51"])
    params.number.should eq(51)
  end

  it "reads an int option" do
    params = IntOption.new(["--number", "42"])
    params.number.should eq(42)
  end

  it "reads an int option with a default value" do
    params = IntDefaultOption.new(Array(String).new)
    params.number.should eq(42)
  end

  it "overwrites an int option with a default value" do
    params = IntDefaultOption.new(["--number", "51"])
    params.number.should eq(51)
  end

  it "reads a float" do
    params = FloatOption.new(["--number", "3.14"])
    params.number.should eq(3.14_f32)
  end

  it "reads an option with =" do
    params = IntOption.new(["--number=10"])
    params.number.should eq(10)
  end

  it "works with a complex case 1" do
    params = ComplexParams.new(
      [
        "--no-effect",
        "--name", "Alexandre",
        "file",
      ]
    )
    params.effect.should be_false
    params.name.should eq("Alexandre")
    params.size.should eq(4)
    params.input.should eq("file")
    params.output.should eq("out")
  end

  it "works with a complex case 2" do
    params = ComplexParams.new(
      [
        "--name", "Alexandre",
        "--size", "8",
        "file",
        "file.out",
      ]
    )
    params.effect.should be_true
    params.name.should eq("Alexandre")
    params.size.should eq(8)
    params.input.should eq("file")
    params.output.should eq("file.out")
  end

  it "requires params on a complex case 1" do
    ex = expect_raises(Clip::ParsingError) do
      ComplexParams.new(["--effect", "file"])
    end

    ex.options.should eq({"name" => Clip::Errors::Required})
    ex.arguments.size.should eq(0)
  end

  it "requires params on a complex case 2" do
    ex = expect_raises(Clip::ParsingError) do
      ComplexParams.new(["--size", "4"])
    end

    ex.options.should eq({"name" => Clip::Errors::Required})
    ex.arguments.should eq({"input" => Clip::Errors::Required})
  end
end
