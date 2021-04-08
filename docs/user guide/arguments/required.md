# Required arguments

Arguments are **positional parameters**.

By default:

* an attribute is mapped to an argument if it has no default value
* and so an argument is required

We will see in the next page how we can make an optional argument.

## An implicit argument

Let's take back our initial command:

```Crystal hl_lines="9"
require "clip"

module Mycommand
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

Mycommand.run
```

We defined an attribute `name` which is a string without default value.
**Clip** maps it to an argument, as we already saw.

Let's enjoy it again :)

```console hl_lines="8 12 14 16"
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand --help
Usage: ./bin/mycommand [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --help  Show this message and exit.
$ ./bin/mycommand Alice
Hello Alice
$ ./bin/mycommand 
Error:
  argument is required: NAME
```

## An explicit argument

Like options, we can also explicitly declare our attribute as an argument with the annotation `Clip::Argument`.

```Crystal hl_lines="9"
require "clip"

module Mycommand
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

Mycommand.run
```

It still behaves the same:

```console
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand --help
Usage: ./bin/mycommand [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --help  Show this message and exit.
$ ./bin/mycommand Alice
Hello Alice
$ ./bin/mycommand
Error:
  argument is required: NAME
```
