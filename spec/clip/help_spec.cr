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

struct OneOptionDoc
  include Clip::Mapper

  @[Clip::Doc("This is a value.")]
  getter value = "somevalue"
end

struct TwoOptionsDoc
  include Clip::Mapper

  @[Clip::Doc("This is a value.")]
  getter value = "somevalue"
  @[Clip::Doc("And this is a number.")]
  getter number = 4
end

struct OneArgumentDoc
  include Clip::Mapper

  @[Clip::Doc("This is a value.")]
  getter value : String
end

struct TwoArgumentsDoc
  include Clip::Mapper

  @[Clip::Doc("This is a value.")]
  getter value : String
  @[Clip::Doc("And this is a number.")]
  getter number : Int32
end

struct ArgumentsDocWithIndex
  include Clip::Mapper

  @[Clip::Doc("This is a value.")]
  @[Clip::Argument(idx: 2)]
  getter value : String
  @[Clip::Doc("And this is a number.")]
  @[Clip::Argument(idx = 1)]
  getter number : Int32
  @[Clip::Argument(idx: 3)]
  getter name : String
end

struct OptionAndArgumentDoc
  include Clip::Mapper

  @[Clip::Doc("This is a value.")]
  getter value : String
  @[Clip::Doc("And this is a number.")]
  getter number = 4
end

struct VeryLongDonc
  include Clip::Mapper

  @[Clip::Doc("This is a very very very very very very very very very very very very very very very long doc for an argument.")]
  getter value : String
  @[Clip::Doc("This is a way shorter doc.")]
  getter othervalue : String

  @[Clip::Doc("This is a very very very very very very very very very very very very very very very long doc for an argument.")]
  getter number = 4
  @[Clip::Doc("And this the way we crush the party")]
  getter booze = true
end

describe "Clip::Help" do
  describe ".help" do
    it "default to PROGRAM_NAME" do
      EmptyHelp.help.should eq(
"Usage: #{PROGRAM_NAME}
"
      )
    end

    it "show nothing for a empty command" do
      EmptyHelp.help("empty").should eq(
"Usage: empty
"
      )
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

    it "handles option doc" do
      OneOptionDoc.help("bin").should eq(
        "Usage: bin [OPTIONS]

Options:
  --value TEXT  This is a value.  [default: somevalue]
"
      )
    end

    it "align option doc" do
      TwoOptionsDoc.help("bin").should eq(
        "Usage: bin [OPTIONS]

Options:
  --value TEXT      This is a value.  [default: somevalue]
  --number INTEGER  And this is a number.  [default: 4]
"
      )
    end

    it "handles argument doc" do
      OneArgumentDoc.help("bin").should eq(
        "Usage: bin VALUE

Arguments:
  VALUE  This is a value.  [required]
"
      )
    end

    it "align argument doc" do
      TwoArgumentsDoc.help("bin").should eq(
        "Usage: bin NUMBER VALUE

Arguments:
  NUMBER  And this is a number.  [required]
  VALUE   This is a value.  [required]
"
      )
    end

    it "follow argument index and doc" do
      ArgumentsDocWithIndex.help("bin").should eq(
        "Usage: bin NUMBER VALUE NAME

Arguments:
  NUMBER  And this is a number.  [required]
  VALUE   This is a value.  [required]
  NAME    [required]
"
      )
    end

    it "does not align option and argument doc" do
      OptionAndArgumentDoc.help("bin").should eq(
        "Usage: bin [OPTIONS] VALUE

Arguments:
  VALUE  This is a value.  [required]

Options:
  --number INTEGER  And this is a number.  [default: 4]
"
      )
    end

    it "wrap long doc" do
      VeryLongDonc.help("bin").should eq(
        "Usage: bin [OPTIONS] OTHERVALUE VALUE

Arguments:
  OTHERVALUE  This is a way shorter doc.  [required]
  VALUE       This is a very very very very very very very very very very very
              very very very very long doc for an argument.  [required]

Options:
  --number INTEGER      This is a very very very very very very very very very
                        very very very very very very long doc for an argument.
                        [default: 4]
  --booze / --no-booze  And this the way we crush the party  [default: true]
"
      )
    end
  end
end
