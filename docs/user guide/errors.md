# Errors

When calling `#parse` you should catch errors, unless you want your program to crash in a bad way.
The method can raises 3 different errors.
Those errors have two common properties:

* they inherit from `Clip::Error`
* their message is preformatted and can be shown directly to the user

The first property means you can rescue only `Clip::Errors`, and the second one means you can do `puts ex` or `ex.to_s` (where `ex` is the rescued exception) and you will have a nice message.

!!! Note
    **Clip** does not provide any i18n support for now, so all messages are in english.

## Parsing error

If the parsing of options and arguments failed a `Clip::ParsingError` exception will be raised.
The exception's message is already a ready-to-use message that you can present to the user, but the exception also provides a way to know what happens exactly.

### Options parsing error

The errors related to options parsing are accessible with `Clip::ParsingError#options`.
It returns a `Hash(String, Clip::Errors)`

The key is the name of the option which triggers the error.
If the option was present in the user input, the name used will be kept.
If not, there are two cases: either the option has no names specified with the `Clip::Option` annotation and the default one is used, or the first name in the annotation is used.

The possible errors are:

* `Clip::Errors::InvalidValue`: the value provided for the option is invalid. It could be triggered when integers or floats are expected.
* `Clip::Errors::MissingValue`: a value must be provided for the option but there is no value.
* `Clip::Errors::Required`: the option is required but is not provided.
* `Clip::Errors::Unknown`: the provided option is unknown.

### Arguments parsing error

In the same way, errors related to arguments parsing are accessible with `Clip::ParsingError#arguments`.
It returns a `Hash(String, Clip::Errors)`.

The key is the name of the argument.

The possible errors are:

* `Clip::Errors::InvalidValue`: the value provided for the argument is invalid. It could be triggered when integers or floats are expected.
* `Clip::Errors::Required`: the argument is required but is not provided.

Excess arguments are ignored, hence you will never get an `Unknown` error.

### Example

```Crystal
require "clip"

module Mycommand
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    @[Clip::Option("-r", "--repeat")]
    getter repeat = 1
    @[Clip::Option]
    getter yell : Bool
    getter name : String
  end

  def self.run
    begin
      command = Command.parse
    rescue ex : Clip::ParsingError
      pp! ex.options, ex.arguments
    end
  end
end

Mycommand.run
```

```console
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand --repeat
ex.options   # => {"--yell" => Required, "--repeat" => MissingValue}
ex.arguments # => {"name" => Required}
$ ./bin/mycommand --yell -r yes --name Alice Barbara
ex.options   # => {"-r" => InvalidValue, "--name" => Unknown}
ex.arguments # => {}
```

## Nested commands error

When using nested commands, two exceptions can be raised:

* `Clip::MissingCommand`: a nested command was expected, but none is provided.
* `Clip::UnknownCommand`: the provided nested command is unknown. The command is accessible with `Clip::UnknownCommand.command`.

```Crystal
require "clip"

module Mycommand
  VERSION = "0.1.0"

  abstract struct Command
    include Clip::Mapper

    Clip.add_commands({"hello" => HelloCommand})
  end

  struct HelloCommand < Command
    include Clip::Mapper
  end

  def self.run
    begin
      command = Command.parse
    rescue ex : Clip::MissingCommand
      pp ex
    rescue ex : Clip::UnknownCommand
      pp! ex.command
    end
  end
end

Mycommand.run
```

```console
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand
#<Clip::MissingCommand:Error: you need to provide a command.>
$ ./bin/mycommand goodbye
ex.command # => "goodbye"
```

--8<-- "includes/abbreviations.md"
