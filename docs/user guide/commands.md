# Commands

We have seen how to have options and arguments.
**Clip** also supports _commands_.

You have already used commands, as many CLI applications use them.
For example `shards` has many commands: `install` and `build` are two of them, and you use them by typing `shards install` and `shards build`.

A command has its own options and arguments.
Actually, the struct `Command` that we used until now in this tutorial is already a command.
Nesting other commands under an existing one requires:

* to define the new subcommands as their own type
* to register them inside the wrapping command using the `Clip.add_command` macro

Commands nested with `Clip.add_commands` can also use `Clip.add_commands` to nest other commands.
**Clip** does not enforce any limitation on the nesting level.

!!! Note
    Command are often called _subcommands_.
    **Clip** makes no actual distinction between the command on which we call `#parse` and the nested ones, so we just call them all _commands_.

Let's change our application.
We will move the actual behavior to a command `hello` and create a new one called `goodbye`.

```Crystal hl_lines="6 9-12 14 17-21 23-29 39 40 42 44"
require "clip"

module Myapplication
  VERSION = "0.1.0"

  abstract struct Command
    include Clip::Mapper

    Clip.add_commands({
      "hello"   => HelloCommand,
      "goodbye" => GoodbyeCommand,
    })

    getter repeat = 1
    getter name : String
  end

  struct HelloCommand < Command
    include Clip::Mapper
  end

  struct GoodbyeCommand < Command
    include Clip::Mapper

    @[Clip::Option("--yell")]
    getter yell : Bool? = nil
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

Myapplication.run
```

A lot has changed!

We defined two new types: `HelloCommand` and `GoodbyeCommand`.
Those types inherit from `Command` and define their own options and arguments.
We keep the attributes `repeat` and `name` inside `Command` as both commands use them.


We then register those types as nested commands under `Command` using `Clip.add_commands`.
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
Building: myapplication
$ ./bin/myapplication --help
Usage: ./bin/myapplication COMMAND [ARGS]...

Commands:
  hello
  goodbye
  help     Show this message and exit.
$ ./bin/myapplication hello --help
Usage: ./bin/myapplication hello [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --repeat INTEGER  [default: 1]
  --help            Show this message and exit.
$ ./bin/myapplication hello Alice
Hello Alice
$ ./bin/myapplication hello --repeat 2 Alice
Hello Alice
Hello Alice
$ ./bin/myapplication goodbye --help
Usage: ./bin/myapplication goodbye [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --repeat INTEGER  [default: 1]
  --yell
  --help            Show this message and exit.
$ ./bin/myapplication goodbye Alice
Goodbye Alice
$ ./bin/myapplication goodbye --repeat 2 --yell Alice
GOODBYE ALICE
GOODBYE ALICE
```

You may have noticed that the first help message shows a command `help` but not an option `--help`.
Indeed, as it is using commands, the help is now a command too.
But to simplify the access to the help the `--help` option is still available, although not shown in the help message.
