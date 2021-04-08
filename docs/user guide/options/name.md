# Option name

By default **Clip** will create an option using the attribute as the name.
The only change that it does is substituting underscores with hyphen.

But you may want to change the option's name, and that is what we will now see.

## Changing the option name

To do that, we just need to use the annotation `Clip::Option`.

```Crystal hl_lines="9"
require "clip"

module Mycommand
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    @[Clip::Option("--times")]
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

**Clip** well use the name given to the annotation instead of the attribute's name:

```console hl_lines="11 15"
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand --help
Usage: ./bin/mycommand [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --times INTEGER  [default: 1]
  --help           Show this message and exit.
$ ./bin/mycommand Alice
Hello Alice
$ ./bin/mycommand --times 2 Alice
Hello Alice
Hello Alice
```

## Short options

Sometime typing the full option's name can be tedious.
Many commands offer short aliases for common options.

To define them, we still use the annotation `Clip::Option`.

```Crystal hl_lines="9"
require "clip"

module Mycommand
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    @[Clip::Option("-t")]
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

What you expect happens:

```console hl_lines="11 15"
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand --help
Usage: ./bin/mycommand [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  -t INTEGER  [default: 1]
  --help      Show this message and exit.
$ ./bin/mycommand Alice
Hello Alice
$ ./bin/mycommand -t 2 Alice
Hello Alice
Hello Alice
```

You may have noticed that the long name is gone.
**Clip** actually *only* uses the name from the annotation.
If you want to use a short name *and* a long name, you have to specify both of them in the annotation:

```Crystal hl_lines="9"
require "clip"

module Mycommand
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    @[Clip::Option("-t", "--times")]
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

Both options `-t` and `--times` are now supported:

```console hl_lines="11 13 16"
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand --help
Usage: ./bin/mycommand [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  -t, --times INTEGER  [default: 1]
  --help               Show this message and exit.
$ ./bin/mycommand -t 2 Alice
Hello Alice
Hello Alice
$ ./bin/mycommand --times 2 Alice
Hello Alice
Hello Alice
```

## Flags

You can use the same annotation to change the name of a flag, short or long.
But if you do so, **Clip** will no longer generate the negative flag (`--no-yell` in our previous example).

The behavior to get a `true` or `false` value changes a little bit and depends on the attribute default value.
When the flag is set:

* if there is no default value, the attribute value will be `true` (and the flag will be required, so it is not very helpful)
* if the default value is `false` or `nil`, the value will be `true`
* if the default value is `true`, the value will be `false`

Here is an example:

```Crystal hl_lines="9-12"
require "clip"

module Mycommand
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    @[Clip::Option("-f", "--feature")]
    getter feature1 = true
    @[Clip::Option("-g")]
    getter feature2 = false
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
      hello(command.name, command.feature1, command.feature2)
    end
  end

  def self.hello(name, feature1, feature2)
    puts "Hello #{name}"
    puts feature1
    puts feature2
  end
end

Mycommand.run
```

```console
$ ./bin/mycommand --help
Usage: ./bin/mycommand [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  -f, --feature  [default: true]
  -g             [default: false]
  --help         Show this message and exit.
$ ./bin/mycommand Alice
Hello Alice
feature1 # => true
feature2 # => false
$ ./bin/mycommand -f Alice
Hello Alice
feature1 # => false
feature2 # => false
$ ./bin/mycommand --feature -g Alice
Hello Alice
feature1 # => false
feature2 # => true
$ ./bin/mycommand -g Alice
Hello Alice
feature1 # => true
feature2 # => true
```
