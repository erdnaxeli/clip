# Multiple values

You may want your options or arguments to accept multiple values.
Think for example of `ls` or `curl`:

```console
$ curl --header "X-First-Name: Jean" --header "X-Last-Name: Martin" http://frenchexample.org/
$ ls file1 file2 file3
```

Here we gave 2 `--headers` to `curl`, and 3 `FILE` argument to `ls`.

**Clip** also supports that.
All you have to do is to declare you option or argument's type as an array.

## Options with multiple value

```Crystal hl_lines="9"
require "clip"

module Mycommand
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    getter name = ["World"]
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

  def self.hello(name)
    puts "Hello #{name.join(", ")}"
  end
end

Mycommand.run
```

```console hl_lines="8 12 13"
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand --help
Usage: ./bin/mycommand [OPTIONS]

Options:
  --name TEXT  [default: [World]]
  --help       Show this message and exit.
$ ./bin/mycommand
Hello World
$ ./bin/mycommand --name Alice --name Barbara --name Chloé
Hello Alice, Barbara, Chloé
```

## Arguments with multiple values

```Crystal hl_lines="9"
require "clip"

module Mycommand
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    getter name : Array(String)
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

  def self.hello(name)
    puts "Hello #{name.join(", ")}"
  end
end

Mycommand.run
```

```console hl_lines="5 8 12 13"
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand --help
Usage: ./bin/mycommand [OPTIONS] NAME...

Arguments:
  NAME  [required]

Options:
  --help  Show this message and exit.
$ ./bin/mycommand Alice Barbara Chloé
Hello Alice, Barbara, Chloé
```

## Supported types

All the types supported for one value are supported for multiple values.
The only exception is the type `Bool`, because it makes no sens to have a flag option repeated multiple times.

The supported types are:

* array of all subtypes of `Int`
* array of all subtypes of `Float`
* `Array(String)`
* and all those types combined with `Nil`

## Default value

Like with options and arguments with only one value, a multiple values options or arguments can have a default value.
If so, it will not be required.

If you want it to not have the message `[default: [value]]` in the help, just set the default value to `nil`.

!!! Warning
    If the default value is `Array(String).new` or `[] of String`, it will be shown **as is** in the help message.

    A better way is to make the type nilable and to set its default value to `nil`.
