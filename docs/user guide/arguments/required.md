# Required arguments

Arguments are **positional parameters**.

By default:

* an attribute is mapped to an argument if it has no default value
* and as it has no default value, it is required

We will see in the next page how to make an argument optional.

## An implicit argument

Let's take back our initial application:

```Crystal hl_lines="9"
require "clip"

module Myapplication
  VERSION = "0.1.0"

  struct Command
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

We defined an attribute `name` with a `String` type and no default value.
**Clip** maps it to an argument, as we already saw.

Let's enjoy it again :)

```console hl_lines="8 12 14 16"
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication --help
Usage: ./bin/myapplication [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --help  Show this message and exit.
$ ./bin/myapplication Alice
Hello Alice
$ ./bin/myapplication
Error:
  argument is required: NAME
```

## An explicit argument

Like options, we can also explicitly declare our attribute as an argument with the annotation `Clip::Argument`.

```Crystal hl_lines="9"
require "clip"

module Myapplication
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    @[Clip::Argument]
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
      hello(command.name)
    end
  end

  def self.hello(name : String)
    puts "Hello #{name}"
  end
end

Myapplication.run
```

It still behaves the same:

```console
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication --help
Usage: ./bin/myapplication [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --help  Show this message and exit.
$ ./bin/myapplication Alice
Hello Alice
$ ./bin/myapplication
Error:
  argument is required: NAME
```
