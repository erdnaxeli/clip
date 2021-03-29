require "./spec_helper.cr"

struct EmptyHelp
  include Clip::Mapper
end

struct FlagOptionHelp
  include Clip::Mapper

  getter flag : Bool? = nil
end

struct StringOptionHelp
  include Clip::Mapper

  getter value : String? = nil
end

struct IntOptionHelp
  include Clip::Mapper

  getter value : Int32? = nil
end

struct FloatOptionHelp
  include Clip::Mapper

  getter value : Float32? = nil
end

struct DefaultFlagOptionHelp
  include Clip::Mapper

  getter flag = true
end

struct DefaultStringOptionHelp
  include Clip::Mapper

  getter value = "somevalue"
end

struct DefaultIntOptionHelp
  include Clip::Mapper

  getter value = 42
end

struct DefaultFloatOptionHelp
  include Clip::Mapper

  getter value = 4.2
end

struct RequiredFlagOptionHelp
  include Clip::Mapper

  @[Clip::Option]
  getter flag : Bool
end

struct RequiredStringOptionHelp
  include Clip::Mapper

  @[Clip::Option]
  getter value : String
end

struct RequiredIntOptionHelp
  include Clip::Mapper

  @[Clip::Option]
  getter value : Int32
end

struct RequiredFloatOptionHelp
  include Clip::Mapper

  @[Clip::Option]
  getter value : Float32
end

struct ArgumentHelp
  include Clip::Mapper

  @[Clip::Argument]
  getter value : String? = nil
end

struct DefaultArgumentHelp
  include Clip::Mapper

  @[Clip::Argument]
  getter value = "somevalue"
end

struct RequiredArgumentHelp
  include Clip::Mapper

  getter value : String
end

describe "Clip::Help" do
  describe ".help" do
    it "show nothing for a empty command" do
      EmptyHelp.help("empty").should eq("Usage: empty")
    end

    it "handles a flag" do
      FlagOptionHelp.help("bin").should eq(
        "Usage: bin [OPTIONS]

Options:
  --flag / --no-flag
"
      )
    end

    it "handles a string" do
      StringOptionHelp.help("bin").should eq(
        "Usage: bin [OPTIONS]

Options:
  --value TEXT
"
      )
    end

    it "handles a int" do
      IntOptionHelp.help("bin").should eq(
        "Usage: bin [OPTIONS]

Options:
  --value INTEGER
"
      )
    end

    it "handles a float" do
      FloatOptionHelp.help("bin").should eq(
        "Usage: bin [OPTIONS]

Options:
  --value FLOAT
"
      )
    end

    it "handles a flag with a default value" do
      DefaultFlagOptionHelp.help("bin").should eq(
        "Usage: bin [OPTIONS]

Options:
  --flag / --no-flag  [default: true]
"
      )
    end

    it "handles a string option with a default value" do
      DefaultStringOptionHelp.help("bin").should eq(
        "Usage: bin [OPTIONS]

Options:
  --value TEXT  [default: somevalue]
"
      )
    end

    it "handles an int option with a default value" do
      DefaultIntOptionHelp.help("bin").should eq(
        "Usage: bin [OPTIONS]

Options:
  --value INTEGER  [default: 42]
"
      )
    end

    it "handles a float option with a default value" do
      DefaultFloatOptionHelp.help("bin").should eq(
        "Usage: bin [OPTIONS]

Options:
  --value FLOAT  [default: 4.2]
"
      )
    end

    it "handles a required flag" do
      RequiredFlagOptionHelp.help("bin").should eq(
        "Usage: bin [OPTIONS]

Options:
  --flag / --no-flag  [required]
"
      )
    end

    it "handles a required string option" do
      RequiredStringOptionHelp.help("bin").should eq(
        "Usage: bin [OPTIONS]

Options:
  --value TEXT  [required]
"
      )
    end

    it "handles a required int option" do
      RequiredIntOptionHelp.help("bin").should eq(
        "Usage: bin [OPTIONS]

Options:
  --value INTEGER  [required]
"
      )
    end

    it "handles a required float option" do
      RequiredFloatOptionHelp.help("bin").should eq(
        "Usage: bin [OPTIONS]

Options:
  --value FLOAT  [required]
"
      )
    end

    it "handles an argument" do
      ArgumentHelp.help("bin").should eq(
        "Usage: bin [VALUE]

Arguments:
  VALUE
"
      )
    end

    it "handles an argument with a default value" do
      DefaultArgumentHelp.help("bin").should eq(
        "Usage: bin [VALUE]

Arguments:
  VALUE  [default: somevalue]
"
      )
    end

    it "handles a required argument" do
      RequiredArgumentHelp.help("bin").should eq(
        "Usage: bin VALUE

Arguments:
  VALUE  [required]
"
      )
    end
  end
end
