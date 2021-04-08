# Optional arguments

To declare an optional argument, we can use the annotation to declare it explicitly and add a default value.

```Crystal hl_lines="10"
require "clip"

module Mycommand
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    @[Clip::Argument]
    getter name = "Barbara"
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

  def self.hello(name : String)
    puts "Hello #{name}"
  end
end

Mycommand.run
```

**Clip** will see that we added a default value to our attribute `name`, and will not require anymore the argument.

```console hl_lines="8 14"
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand --help
Usage: ./bin/mycommand [OPTIONS] [NAME]

Arguments:
  NAME  [default: Barbara]

Options:
  --help  Show this message and exit.
$ ./bin/mycommand Alice
Hello Alice
$ ./bin/mycommand
Hello Barbara
```
