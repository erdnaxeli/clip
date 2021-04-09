# Commands

So far we have seen how to have options and arguments.
But **Clip** also supports _commands_.

You have already use commands, as many CLI applications use them.
For example `shards` has many commands: `install` and `build` are two of them, and you use them by typing `shards install` and `shards build`.

A command has its own options and arguments.
Actually, the struct `Command` that we used until now in this tutorial is already a command.
Nesting other commands under an existing one require:

* to define the new subcommands as their own type
* to declare inside the wrapping command them using the `Clip.add_command` macro

Commands nested with `Clip.add_commands` can also use `Clip.add_commands` to nest other commands.
**Clip** does not enforce any limitation of the nesting level.

!!! Note
    Command are often called _subcommands_.
    **Clip** makes no actual distinction between the command on which we call `#parse` and the nested ones, so we just call them all _commands_.

Let's change our application.
We will move the actual behavior to a command `hello` and create a new one called `goodbye`.

```Crystal hl_lines="6 9-12 14 17-21 23-29 39 40 42 44"
require "clip"

module Mycommand
  VERSION = "0.1.0"

  abstract struct Command
    include Clip::Mapper

    Clip.add_commands({
      "hello"   => HelloCommand,
      "goodbye" => GoodbyeCommand,
    })

    getter repeat = 1
  end

  struct HelloCommand < Command
    include Clip::Mapper

    getter name : String
  end

  struct GoodbyeCommand < Command
    include Clip::Mapper

    @[Clip::Option("--yell")]
    getter yell : Bool? = nil
    getter name : String
  end

  def self.run
    begin
      command = Command.parse
    rescue ex : Clip::Error
      puts ex
      return
    end

    case command
    when Clip::Mapper::Help
      puts command.help
    when HelloCommand
      hello(command.name, command.repeat)
    when GoodbyeCommand
      goodbye(command.name, command.repeat, command.yell)
    end
  end

  def self.hello(name, repeat)
    repeat.times { puts "Hello #{name}" }
  end

  def self.goodbye(name, repeat, yell)
    msg = "Goodbye #{name}\n" * repeat

    if yell
      puts msg.upcase
    else
      puts msg
    end
  end
end

Mycommand.run
```

A lot have changed!

We define two new types: `HelloCommand` and `GoodbyeCommand`.
Those types inherit from `Command` and define their own options and arguments.
We keep the attribute `repeat` inside `Command` as both commands will use it.


We then declare those types as nested commands under `Command` using `Clip.add_commands`.
The `Command#parse` method changes to now dispatch the parsing to `HelloCommand` or `GoodbyeCommand` according to the user input.

To check what command the user want to run, we use a `case` clause on the type of the returned object.

!!! Tip
    We used a Hash as the `Clip.add_commands` parameter but a NamedTuple would have worked too.

!!! Note
    Structs cannot be inherited, only abstract struct can, that's why `Command` is now abstract.
    But that's not a problem as it will never be instantiated now that it has nested commands.

We can check that our two commands behave as expected:

```console
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand --help
Usage: ./bin/mycommand COMMAND [ARGS]...

Commands:
  hello
  goodbye
  help     Show this message and exit.
$ ./bin/mycommand hello --help
Usage: ./bin/mycommand hello [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --repeat INTEGER  [default: 1]
  --help            Show this message and exit.
$ ./bin/mycommand hello Alice
Hello Alice
$ ./bin/mycommand hello --repeat 2 Alice
Hello Alice
Hello Alice
$ ./bin/mycommand goodbye --help
Usage: ./bin/mycommand goodbye [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --repeat INTEGER  [default: 1]
  --yell
  --help            Show this message and exit.
$ ./bin/mycommand goodbye Alice
Goodbye Alice
$ ./bin/mycommand goodbye --repeat 2 --yell Alice
GOODBYE ALICE
GOODBYE ALICE
```

You may have noticed than the first help message shows a command `help` but not an option `--help`.
Indeed, as it is using commands, the help is now a command too.
But to simplify the access to the help the `--help` option is still available, although not shown in the help message.
