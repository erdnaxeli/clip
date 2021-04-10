# Nilable options

You may have noticed that **Clip** adds in the help message if the option have a default value or is required.
It looks like this:

```console
  --repeat INTEGER  [default: 1]
```

or

```console
  --repeat INTEGER  [required]
```

Sometime you may not want those messages to be shown.
Maybe you want the option to be optional and have a default value, but you don't want to expose this value to the user.

What you can do is making the attribute's type nilable and set a default value `nil`:

```Crystal hl_lines="10 30"
require "clip"

module Mycommand
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

Mycommand.run
```

!!! Tip
    As our attribute does have a default value we don't have to explicitly add the `Clip::Option` annotation.

!!! Note
    `command.repeat` is now either an `Int32` or a `Nil` value, so we can't directly call `#times` on it or the compiler will complain that this method is not defined for `Nil`.

Now the help looks like this:

```console hl_lines="11"
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand --help
Usage: ./bin/mycommand [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --repeat INTEGER
  --help            Show this message and exit.
```

The behavior is still the same:
```console
$ ./bin/mycommand Alice
Hello Alice
$ ./bin/mycommand --repeat 2 Alice
Hello Alice
Hello Alice
```

Whether you choose to use a default `nil` value or not is on you!
