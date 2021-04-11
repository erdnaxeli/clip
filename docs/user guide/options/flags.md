# Flags

A flag is a special option that has no value, at least from a user perspective.
The flag actually does have a value, but it is a boolean.

Common flags you may have encountered already are `--verbose` or `--debug`.
They are usually used to enabled or disabled a feature.

## Default flag

A flag is boolean option, so all we need to do is define an attribute with a `Bool` type.

```Crystal hl_lines="9"
require "clip"

module Myapplication
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

Myapplication.run
```

**Clip** generate two options for each flag:

* one for a `true` value
* the other for the `false` value

```console hl_lines="11"
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication --help
Usage: ./bin/myapplication [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --yell / --no-yell  [default: false]
  --help              Show this message and exit.
$ ./bin/myapplication Alice
Hello Alice
$ ./bin/myapplication --yell Alice
HELLO ALICE
$ ./bin/myapplication --no-yell Alice
Hello Alice
```

## Required flag

As any option, a flag can be required:

```Crystal hl_lines="9 10"
require "clip"

module Myapplication
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

Myapplication.run
```

No setting the flag is now an error:

```console hl_lines="11 15"
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication --help
Usage: ./bin/myapplication [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --yell / --no-yell  [required]
  --help              Show this message and exit.
$ ./bin/myapplication Alice
Error:
  option is required: --yell
$ ./bin/myapplication --yell Alice
HELLO ALICE
$ ./bin/myapplication --no-yell Alice
Hello Alice
```

## Nilable flag

A flag can also have a default value `nil`:

```Crystal hl_lines="9 10 29"
require "clip"

module Myapplication
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
    if yell
      puts "Hello #{name}".upcase
    else
      puts "Hello #{name}"
    end
  end
end

Myapplication.run
```

!!! Tip
    As `nil` is a falsy value  we don't have to write `if !yell.nil? && yell`.

```console hl_lines="11"
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication --help
Usage: ./bin/myapplication [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --yell / --no-yell
  --help              Show this message and exit.
$ ./bin/myapplication Alice
Hello Alice
$ ./bin/myapplication --yell Alice
HELLO ALICE
$ ./bin/myapplication --no-yell Alice
Hello Alice
```
