# Required options

An option can also be required.
Now that we know how to declare an explicit option, all that we have to do is remove the default value.
**Clip** will know that the option is now required.

```Crystal hl_lines="10"
require "clip"

module Myapplication
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    @[Clip::Option]
    getter repeat : Int32
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

Myapplication.run
```

!!! Note
    Now that we removed the default value, we have to specify the type of the attribute `repeat` so the compiler (and Clip) knows it.

It now complains if we don't provide the option:

```console hl_lines="11 13 15"
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication --help
Usage: ./bin/myapplication [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --repeat INTEGER  [required]
  --help            Show this message and exit.
$ ./bin/myapplication Alice
Error:
  option is required: --repeat
$ ./bin/myapplication --repeat 1 Alice
Hello Alice
$ ./bin/myapplication --repeat 2 Alice
Hello Alice
Hello Alice
```
