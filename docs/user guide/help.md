# Help

**Clip** generates for your commands an help message, respecting the known convention used since decades by many CLI applications, as we already seen it in the previous sections.

## The `#help` method

When the module `Clip::Mapper` is included, three methods are generated:

* `#initialize`
* `#parse`
* and `#help`

The `#help` method returns the help message:

```Crystal hl_lines="14"
require "clip"

module Mycommand
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

Mycommand.run
```

```console
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand
Usage: ./bin/mycommand [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --repeat INTEGER  [default: 1]
  --help            Show this message and exit.
```

This method accepts one parameter that will be used as the program's name.
The default value is `PROGRAM_NAME`.
You can also give it a `nil` parameter, this will be useful for [non CLI appliaction](non_cli_app.md).

```Crystal hl_lines="14 16"
require "clip"

module Mycommand
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

Mycommand.run
```

```console hl_lines="5 14"
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand
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

The `#help` method is fine, but it does not work when you have nested commands.
As it is called on the method itself, it has no context about the command being nested or not.

See this example:
```Crystal hl_lines="9 21"
require "clip"

module Mycommand
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

Mycommand.run
```

```console hl_lines="5"
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand
Usage: ./bin/mycommand [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --repeat INTEGER  [default: 1]
  --help            Show this message and exit.
```

Here the usage shown is wrong.
If you try this to excute `./bin/mycommand Alice` it will actually complains that `Alice` is an unknown command.

Futhermore, you probably want to show the help when the user ask for it.
And you can try, but setting an `--help` option yourself would require to define all other options and arguments as optional, as you probably don't want that `./bin/mycommand --help` complains about `NAME` not being set.
And setting everything optional defeat the purpose of having a library checking for required options an arguments for you.

So to fix all that **Clip** provide a special mechanism for the help.
We actually already seen it.

When using `#parse`, **Clip** will check _before the parsing_ if the user input contains `--help` (or `help` if the command has nested commands).
If it is the case, it will return a special object `Help`.
The parsing will not be done, so missing required options or arguments will not raise an error.

The `Help` object has two properties:

* it inherits from `Clip::Mapper::Help`
* it expose a method `#help`

The first property is useful when using nested commands.
The `Help` type is generated for each command, so without this property you would have to check if the returned value from `#parse` is an `Help` object _for each available command_.
Instead you can just check if the type is `Clip::Mapper::Help`.

The second property is also useful when using nested commands.
`Help#help` behaves like the `#help` method generated on your command, excepts __it has context about nested commands__.

Let's fix our previous example with a nested command:

```Crystal hl_lines="9 28-30"
require "clip"

module Mycommand
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

Mycommand.run
```

The help is now correct:

```console hl_lines="5"
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand hello --help
Usage: ./bin/mycommand hello [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --repeat INTEGER  [default: 1]
  --help            Show this message and exit.
```
