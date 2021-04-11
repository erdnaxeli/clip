# Nilable options

You may have noticed that **Clip** adds in the help message if the option has a default value or is required.
It looks like this:

```console
  --repeat INTEGER  [default: 1]
```

or

```console
  --repeat INTEGER  [required]
```

Sometimes you may not want those messages to be shown.
Maybe you want the option to be optional and have a default value, but you don't want to expose this value to the user.

We can do this by making the attribute's type nilable and set its default value `nil`:

```Crystal hl_lines="9 29"
require "clip"

module Myapplication
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    getter repeat : Int32? = nil
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
    if repeat.nil?
      puts "Hello #{name}"
    else
      repeat.times { puts "Hello #{name}" }
    end
  end
end

Myapplication.run
```

!!! Tip
    As our attribute does have a default value we don't have to explicitly add the `Clip::Option` annotation.

!!! Note
    `command.repeat` is now either an `Int32` or a `Nil` value, so we can't directly call `#times` on it or the compiler will complain that this method is not defined for `Nil`.

The help now looks like this:

```console hl_lines="11"
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication --help
Usage: ./bin/myapplication [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --repeat INTEGER
  --help            Show this message and exit.
```

And the behavior is still the same:
```console
$ ./bin/myapplication Alice
Hello Alice
$ ./bin/myapplication --repeat 2 Alice
Hello Alice
Hello Alice
```

Whether you choose to use a default `nil` value or not is up to you.
