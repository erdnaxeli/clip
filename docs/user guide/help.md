# Help

**Clip** generates an help message for every commands, respecting the known conventions used since decades by many CLI applications, as we already seen it in the previous sections.

## The `#help` method

When the module `Clip::Mapper` is included, three methods are generated:

* `#initialize`
* `#parse`
* and `#help`

The `#help` method returns the help message:

```Crystal hl_lines="14"
require "clip"

module Myapplication
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    getter repeat = 1
    getter name : String
  end

  def self.run
    puts Command.help
  end
end

Myapplication.run
```

```console
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication
Usage: ./bin/myapplication [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --repeat INTEGER  [default: 1]
  --help            Show this message and exit.
```

This method accepts one parameter: the program's name.
The default value is `PROGRAM_NAME`.
You can set it to `nil`, which is useful for [non CLI appliaction](non_cli_app.md).

```Crystal hl_lines="14 16"
require "clip"

module Myapplication
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    getter repeat = 1
    getter name : String
  end

  def self.run
    puts Command.help("tutorialapp")
    puts "---"
    puts Command.help(nil)
  end
end

Myapplication.run
```

```console hl_lines="5 14"
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication
Usage: tutorialapp [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --repeat INTEGER  [default: 1]
  --help            Show this message and exit.
---
Usage: [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --repeat INTEGER  [default: 1]
  --help            Show this message and exit.
```

# The `Help` object

The `#help` method is fine, but it does not work with nested commands.
As it is called on the command itself, it has no context about the command being nested or not.

See this example:
```Crystal hl_lines="9 21"
require "clip"

module Myapplication
  VERSION = "0.1.0"

  abstract struct Command
    include Clip::Mapper

    Clip.add_commands({"hello" => HelloCommand})

    getter repeat = 1
  end

  struct HelloCommand < Command
    include Clip::Mapper

    getter name : String
  end

  def self.run
    puts HelloCommand.help
  end
end

Myapplication.run
```

```console hl_lines="5"
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication
Usage: ./bin/myapplication [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --repeat INTEGER  [default: 1]
  --help            Show this message and exit.
```

Here the usage shown is wrong.
If you try this to excute `./bin/myapplication Alice` it will actually complains that `Alice` is an unknown command.

Futhermore, you probably want to show the help when the user ask for it.
And you can try, but setting an `--help` option yourself would require to define all other options and arguments as optional, as you probably don't want that `./bin/myapplication --help` complains about `NAME` not being set.
And setting everything optional defeat the purpose of having a library validating required options an arguments for you.

So to fix all that **Clip** provides a special mechanism for the help.
We have used it already.

When using `#parse`, **Clip** checks _before the parsing_ if the user input contains `--help` (or `help` if the command has nested commands).
If it is the case, it returns a special object `Help`.
The parsing is not done, so missing required options or arguments don't raise an error.

The `Help` object has two properties:

* it inherits from `Clip::Mapper::Help`
* it exposes a method `#help`

The first property is useful when using nested commands.
The `Help` type is generated for each command, so without this property you would have to check if the returned value from `#parse` is an `Help` object _for each available command_.
Instead you can just check if the type is `Clip::Mapper::Help`.

The second property is also useful when using nested commands.
`Help#help` behaves like the `#help` method generated on your command, excepts __it has context about nested commands__.

Let's fix our previous example with a nested command:

```Crystal hl_lines="9 28-30"
require "clip"

module Myapplication
  VERSION = "0.1.0"

  abstract struct Command
    include Clip::Mapper

    Clip.add_commands({"hello" => HelloCommand})

    getter repeat = 1
  end

  struct HelloCommand < Command
    include Clip::Mapper

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
      # command is actually an HelloCommand::Help instance
      puts command.help
    end
  end
end

Myapplication.run
```

The help is now correct:

```console hl_lines="5"
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication hello --help
Usage: ./bin/myapplication hello [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --repeat INTEGER  [default: 1]
  --help            Show this message and exit.
```
