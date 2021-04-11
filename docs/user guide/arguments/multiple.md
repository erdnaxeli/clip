# Multiple arguments

So far we only used one argument, but it is not uncommon for a command to support multiple arguments.

To do that with **Clip** we just have to define other attributes:

```Crystal hl_lines="9 10"
require "clip"

module Myapplication
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    getter repeat : Int32
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
    repeat.time { puts "Hello #{name}" }
  end
end

Myapplication.run
```

Our command has now two arguments: `NAME` and `REPEAT`.

```console hl_lines="5 8-9 13"
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication --help
Usage: ./bin/myapplication [OPTIONS] NAME REPEAT

Arguments:
  NAME    [required]
  REPEAT  [required]

Options:
  --help  Show this message and exit.
$ ./bin/myapplication 2 Alice
Hello Alice
Hello Alice
```

## Arguments ordering

You may have noticed something strange in the previous example.
The usage says "NAME REPEAT" but I wrote "2 Alice", so "REPEAT NAME".
Unfortunately, this behavior comes from the Crystal compiler itself.

When we include `Clip::Mapper`, two macros are run to generate the parser and the help message.
Those macros rely on `TypeNode#instance_vars` to get all the type's attributes.
Sadly, this method does not always return the attributes as they were ordered in the type declaration.
Even sadder, multiple calls can return attributes in a different order.
With our example the parser saw `repeat` and then `name`, but the help saw `name` and then `repeat`.

That's why **Clip** provides a way to ensure the arguments ordering.
It is done with the annotation `Clip::Argument`, with a named parameter `idx`:

```Crystal hl_lines="9 11"
require "clip"

module Myapplication
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    @[Clip::Argument(idx: 1)]
    getter repeat : Int32
    @[Clip::Argument(idx: 2)]
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
    repeat.time { puts "Hello #{name}" }
  end
end

Myapplication.run
```

The arguments are now correctly ordered both in the help message and in the parser:

```console hl_lines="5 13"
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication --help
Usage: ./bin/myapplication [OPTIONS] REPEAT NAME

Arguments:
  REPEAT  [required]
  NAME    [required]

Options:
  --help  Show this message and exit.
$ ./bin/myapplication 1 Alice
Hello Alice
```

## Arguments consuming order

A little note about how the argument are _consummed_ from the user input.
Let's take the following command definition:

```console
Usage: ./bin/myapplication [OPTIONS] REPEAT NAME
```

This command has two required arguments.
**Clip** always consumes arguments from **left to right**.
So if the user input is `./bin/myapplication 2 Alice`, **Clip** consumes `2` and uses it as the value for `REPEAT`, then it consumes `Alice` and uses it as the value for `NAME`.

So far so good.
But what if we make `REPEAT` an optional argument?
The command definition now looks like this:

```console
Usage: ./bin/myapplication [OPTIONS] [REPEAT] NAME
```

When we give both arguments, **Clip** maps them both, and everything is ok.
But if we give only one argument, **Clip** still maps it with `REPEAT`, as it consumes arguments from left to right.
Then it finds no value for `NAME` and raises an error:

```Crystal hl_lines="10"
require "clip"

module Myapplication
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    @[Clip::Argument(idx: 1)]
    getter repeat = 1
    @[Clip::Argument(idx: 2)]
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

Myapplication.run
```

```console hl_lines="5 8 16-19"
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication --help
Usage: ./bin/myapplication [OPTIONS] [REPEAT] NAME

Arguments:
  REPEAT  [default: 1]
  NAME    [required]

Options:
  --help  Show this message and exit.
$ ./bin/myapplication 2 Alice
Hello Alice
Hello Alice
$ ./bin/myapplication Alice
Error:
  argument's value is invalid: REPEAT
  argument is required: NAME
```

Let's make `NAME` optional instead:

```Crystal hl_lines="10 12"
require "clip"

module Myapplication
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    @[Clip::Argument(idx: 1)]
    getter repeat : Int32
    @[Clip::Argument(idx: 2)]
    getter name = "Barbara"
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

Myapplication.run
```

If we give only one argument **Clip** maps it to `REPEAT`, and as `NAME` is optional no error is raised:

```console hl_lines="5 8 9 16"
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication --help
Usage: ./bin/myapplication [OPTIONS] REPEAT [NAME]

Arguments:
  REPEAT  [required]
  NAME    [default: Barbara]

Options:
  --help  Show this message and exit.
$ ./bin/myapplication 2 Alice
Hello Alice
Hello Alice
$ ./bin/myapplication 1
Hello Barbara
```

To resume:

* you can use multiple arguments
* arguments are consumed from left to right
* hence optional arguments must be the last ones

!!! Note
    This is fully dependant on the current implementation of **Clip** and you may find other libraries without this constraint.
