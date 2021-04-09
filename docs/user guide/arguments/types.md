# Arguments types

So far we seen two type for an argument: `String` and `String?`.
But like options, you can use numeric types too.

The supported types are:

* all subtypes of `Int`: `Int32`, `UInt32`, and all others
* all subtypes of `Float`: `BigFloat`, `Float32` and `Float64`
* `Bool`
* `String`
* and all those types combined with `Nil`: `Int32?`, `Float32?`, `String?`, and so on.

`Bool` is not supported, and can only be used with a flag.

During the parsing, **Clip** will try to convert the string to the attribute's type.
If any error happens, a `Clip::ParsingError` will be raised (see the [errors section](../errors.md) for details).

```Crystal hl_lines="9"
require "clip"

module Mycommand
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    getter name : Int32
  end

  def self.run
    begin
      command = Command.parse
    rescue ex : Clip::Error
      puts ex
      return
    end

    if command.is_a?(Clip::Mapper::Help)
      puts command.help
    else
      hello(command.name)
    end
  end

  def self.hello(name)
    puts "Hello #{name}"
  end
end

Mycommand.run
```

```console hl_lines="14"
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand --help
Usage: ./bin/mycommand [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --help  Show this message and exit.
$ ./bin/mycommand Alice
Error:
  argument's value is invalid: NAME
$ ./bin/mycommand 42   
Hello 42
```
