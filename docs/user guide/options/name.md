# Option name

By default **Clip** creates the option using the attribute as its name.
The only change it does is substituting underscores with hyphen.

But you can change the option's name, as we will see.

## Changing the option name

To do that we use again the annotation `Clip::Option`.

```Crystal hl_lines="9"
require "clip"

module Myapplication
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

Myapplication.run
```

**Clip** uses the name given to the annotation instead of the attribute's name:

```console hl_lines="11 15"
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication --help
Usage: ./bin/myapplication [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --times INTEGER  [default: 1]
  --help           Show this message and exit.
$ ./bin/myapplication Alice
Hello Alice
$ ./bin/myapplication --times 2 Alice
Hello Alice
Hello Alice
```

## Short options

Sometime typing the full option's name can be tedious.
Many commands offer short aliases for common options.

To define them, we still use the annotation `Clip::Option`.

```Crystal hl_lines="9"
require "clip"

module Myapplication
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

Myapplication.run
```

What you expect happens:

```console hl_lines="11 15"
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication --help
Usage: ./bin/myapplication [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  -t INTEGER  [default: 1]
  --help      Show this message and exit.
$ ./bin/myapplication Alice
Hello Alice
$ ./bin/myapplication -t 2 Alice
Hello Alice
Hello Alice
```

You may have noticed that the long name is gone.
**Clip** actually *only* uses the name from the annotation.
If you want to use a short name *and* a long name, you have to specify both of them in the annotation:

```Crystal hl_lines="9"
require "clip"

module Myapplication
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

Myapplication.run
```

Both options `-t` and `--times` are now supported:

```console hl_lines="11 13 16"
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication --help
Usage: ./bin/myapplication [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  -t, --times INTEGER  [default: 1]
  --help               Show this message and exit.
$ ./bin/myapplication -t 2 Alice
Hello Alice
Hello Alice
$ ./bin/myapplication --times 2 Alice
Hello Alice
Hello Alice
```

## Flags

You can use the same annotation to change the name of a flag, short or long.
But if you do, **Clip** no longer generates the negative flag (`--no-yell` in our previous example).

The behavior to get a `true` or `false` value changes a little bit and depends on the attribute's default value.
When the flag is set:

* if there is no default value, the attribute value will be `true` (and the flag will be required, so it is not very helpful)
* if the default value is `false` or `nil`, the value will be `true`
* if the default value is `true`, the value will be `false`

Here is an example:

```Crystal hl_lines="9-13"
require "clip"

module Myapplication
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    @[Clip::Option("-f", "--feature")]
    getter feature1 = true
    @[Clip::Option("-g")]
    getter feature2 = false
    getter feature3 : Bool? = nil
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
      hello(command.feature1, command.feature2, command.feature3)
    end
  end

  def self.hello(feature1, feature2, feature3)
    p! feature1
    p! feature2
    p! feature3
  end
end

Myapplication.run
```

```console
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication --help
Usage: ./bin/myapplication [OPTIONS]

Options:
  --feature3 / --no-feature3
  -f, --feature               [default: true]
  -g                          [default: false]
  --help                      Show this message and exit.
$ ./bin/myapplication
feature1 # => true
feature2 # => false
feature3 # => nil
$ ./bin/myapplication -f
feature1 # => false
feature2 # => false
feature3 # => nil
$ ./bin/myapplication --feature
feature1 # => false
feature2 # => false
feature3 # => nil
$ ./bin/myapplication -g
feature1 # => true
feature2 # => true
feature3 # => nil
$ ./bin/myapplication --feature3
feature1 # => true
feature2 # => false
feature3 # => true
```
