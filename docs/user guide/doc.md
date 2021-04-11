# Documentation

An help message showing all available options and arguments is great, but an help message documenting them is better!

**Clip** allows you to add a documentation to options, arguments, and commands, all using the same annotation `Clip::Doc`.
Let's document our command:

```Crystal hl_lines="6 10 12"
require "clip"

module Myapplication
  VERSION = "0.1.0"

  @[Clip::Doc("Greet a person, one or many times.")]
  struct Command
    include Clip::Mapper

    @[Clip::Doc("How many times to greet the person.")]
    getter repeat = 1
    @[Clip::Doc("The name of the person to greet.")]
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

See how beautiful our help is now:

```console hl_lines="7 10 13"
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication --help
Usage: ./bin/myapplication [OPTIONS] NAME

Greet a person, one or many times.

Arguments:
  NAME  The name of the person to greet.  [required]

Options:
  --repeat INTEGER  How many times to greet the person.  [default: 1]
  --help            Show this message and exit.
```

You may have noticed that the documentation for both options `--repeat` and `--help` are aligned.
If you have many arguments, their documentation will be aligned too.

If a documentation is too big to fit in a 80 chars long line, it is nicely wrapped:

```Crystal hl_lines="6-9 13-16"
require "clip"

module Myapplication
  VERSION = "0.1.0"

  @[Clip::Doc("Greet a person, one or many times. This fictitious command " \
              "is actually used to demonstrated all the capabilities of " \
              "Clip, a Crystal library to deserialize CLI parameters to " \
              "a user defined object.")]
  struct Command
    include Clip::Mapper

    @[Clip::Doc("How many times to greet the person. Note that greeting " \
                "someone too many times in a row could be really annoying, " \
                "and you should probably no do that in real life, unless " \
                "you are a sitcom character.")]
    getter repeat = 1
    @[Clip::Doc("The name of the person to greet.")]
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

The command's doc and the `--repeat` option's doc are nicely wrapped:

```console hl_lines="7-9 15-18"
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication --help
Usage: ./bin/myapplication [OPTIONS] NAME

Greet a person, one or many times. This fictitious command is actually used to
demonstrated all the capabilities of Clip, a Crystal library to deserialize CLI
parameters to a user defined type.

Arguments:
  NAME  The name of the person to greet.  [required]

Options:
  --repeat INTEGER  How many times to greet the person. Note that greeting
                    someone too many times in a row could be really annoying,
                    and you should probably no do that in real life, unless you
                    are a sitcom character.  [default: 1]
  --help            Show this message and exit.
```
