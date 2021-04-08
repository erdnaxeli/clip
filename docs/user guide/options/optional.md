# Optionnal options

Options are **named parameters**.

By default:

* an attribute is mapped to an option if it has a default value,
* and so an option is optional

We will see in the next page how this can be changed.

## An implicit option

First, we will add an option to our command:

```Crystal hl_lines="9 24 28 29"
require "clip"

module Mycommand
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    getter repeat = 1
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

!!! Tip
    We don't have to specify the type of the attribute `repeat`, as the compiler will infer that it is an `Int32`.

Let's try our new option:
```console hl_lines="11 15"
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand --help
Usage: ./bin/mycommand [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --repeat INTEGER  [default: 1]
  --help            Show this message and exit.
$ ./bin/mycommand Alice
Hello Alice
$ ./bin/mycommand --repeat 2 Alice
Hello Alice
Hello Alice
```

It all works as expected: the option `--repeat` is optional and has a default value.

You can also use an `=` character to define the value:
```console
$ ./bin/mycommand --repeat=2 Alice
Hello Alice
Hello Alice
```

## An explicit option

We can also explicitly declare our attribute as an option.
We use for that the annotation `Clip::Option`.

```Crystal hl_lines="9"
require "clip"

module Mycommand
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    @[Clip::Option]
    getter repeat = 1
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

Nothing should have changed:

```console
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand --help
Usage: ./bin/mycommand [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --repeat INTEGER  [default: 1]
  --help            Show this message and exit.
$ ./bin/mycommand Alice
Hello Alice
$ ./bin/mycommand --repeat 2 Alice
Hello Alice
Hello Alice
```
