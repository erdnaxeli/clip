# Optional arguments

An argument can also be optional.
Now that we know how to declare an explicit argument, all that we have to do is add a default value.
**Clip** will know that the argument is now optional.

```Crystal hl_lines="10"
require "clip"

module Myapplication
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

Myapplication.run
```

!!! Tip
    As we added a default value, we can remove the type restriction.
    Crystal infers it from the default value.

`NAME` is not required anymore:

```console hl_lines="8 14"
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication --help
Usage: ./bin/myapplication [OPTIONS] [NAME]

Arguments:
  NAME  [default: Barbara]

Options:
  --help  Show this message and exit.
$ ./bin/myapplication Alice
Hello Alice
$ ./bin/myapplication
Hello Barbara
```
