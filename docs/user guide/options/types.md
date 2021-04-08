# Options types

So for we have use two different types for options: integers and booleans.
But you can use more!

The supported types are:
 
* all subtypes of `Int`: `Int32`, `UInt32`, and all others
* all subtypes of `Float`: `BigFloat`, `Float32` and `Float64`
* `Bool`
* `String`
* and all those types combined with `Nil`: `Int32?`, `Float32?`, `Bool?`, `String?`, and so on.

During the parsing, **Clip** will try to convert the string to the attribute's type.
If any error happens, a `Clip::ParsingError` will be raised (see the [errors section](../errors.md) for details).

```Crystal
require "clip"

module Mycommand
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    getter repeat = 1
    getter name : String
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
      hello(command.name, command.repeat)
    end
  end

  def self.hello(name, repeat)
    repeat.times { puts "Hello #{name}" }
  end
end

Mycommand.run
```

```console
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand --repeat two Alice
Error:
  option's value is invalid: --repeat
```
