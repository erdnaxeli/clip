# Required options

An option can also be required.
Now that we know how to declare an explicit option, all that we have to do is to remove the default value.
**Clip** will known that the option is now required.

```Crystal hl_lines="10"
require "clip"

module Mycommand
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

Mycommand.run
```

!!! Note
    Now that we removed the default value, we have to specify the type of the attribute `repeat` so the compiler (and Clip) knows it.

It should now complain if we don't provide the option:

```console hl_lines="11 15"
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand --help
Usage: ./bin/mycommand [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --repeat INTEGER  [required]
  --help            Show this message and exit.
$ ./bin/mycommand Alice
Error:
  option is required: --repeat
$ ./bin/mycommand --repeat 1 Alice
Hello Alice
$ ./bin/mycommand --repeat 2 Alice
Hello Alice
Hello Alice
```
