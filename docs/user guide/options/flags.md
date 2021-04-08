# Flags

A flag is a special type of option that has no value.
At least, for a user perspective.
In reality the flag does have a value, but it is a boolean.

Common flags you may have encountered already are `--verbose` or `--debug`. 

## Default flag

A flag is boolean option, so all you need to do is defining an attribute with a `Bool` type.

```Crystal hl_lines="9"
require "clip"

module Mycommand
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    getter yell = false
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
      hello(command.name, command.yell)
    end
  end

  def self.hello(name, yell)
    if yell
      puts "Hello #{name}".upcase
    else
      puts "Hello #{name}"
    end
  end
end

Mycommand.run
```

**Clip** generate two options for flag, one for a `true` value, and the other for the `false` value:

```console hl_lines="11"
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand --help
Usage: ./bin/mycommand [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --yell / --no-yell  [default: false]
  --help              Show this message and exit.
$ ./bin/mycommand Alice
Hello Alice
$ ./bin/mycommand --yell Alice
HELLO ALICE
$ ./bin/mycommand --no-yell Alice
Hello Alice
```

## Required flag

As any option, a flag can be required:

```Crystal hl_lines="9 10"
require "clip"

module Mycommand
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    @[Clip::Option]
    getter yell : Bool
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
      hello(command.name, command.yell)
    end
  end

  def self.hello(name, yell)
    if yell
      puts "Hello #{name}".upcase
    else
      puts "Hello #{name}"
    end
  end
end

Mycommand.run
```

No setting the flag is now an error:

```console hl_lines="11 15"
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand --help
Usage: ./bin/mycommand [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --yell / --no-yell  [required]
  --help              Show this message and exit.
$ ./bin/mycommand Alice
Error:
  option is required: --yell
$ ./bin/mycommand --yell Alice
HELLO ALICE
$ ./bin/mycommand --no-yell Alice
Hello Alice
```

## Nillable flag

A flag can also have a default value `nil`:

```Crystal hl_lines="9 10 29"
require "clip"

module Mycommand
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

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

    if command.is_a?(Clip::Mapper::Help)
      puts command.help
    else
      hello(command.name, command.yell)
    end
  end

  def self.hello(name, yell)
    if !yell.nil? && yell
      puts "Hello #{name}".upcase
    else
      puts "Hello #{name}"
    end
  end
end

Mycommand.run
```

```console hl_lines="11"
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand --help
Usage: ./bin/mycommand [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --yell / --no-yell
  --help              Show this message and exit.
$ ./bin/mycommand Alice
Hello Alice
$ ./bin/mycommand --yell Alice
HELLO ALICE
$ ./bin/mycommand --no-yell Alice
Hello Alice
```
