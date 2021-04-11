# Nilable arguments

**Clip** specifies in the help message if an argument is required or not, like this:

```console
  NAME  [required]
```

or

```console
  NAME  [default: Barbara]
```

If you don't want any message, you can declare the attribute's type as nilable and set the default value to `nil`:

```Crystal hl_lines="9 10"
require "clip"

module Myapplication
  VERSION = "0.1.0"

  struct Command
    include Clip::Mapper

    @[Clip::Argument]
    getter name : String? = nil
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

  def self.hello(name)
    if name.nil?
      puts "Hello world!"
    else
      puts "Hello #{name}"
    end
  end
end

Myapplication.run
```

!!! Tip
    Crystal cannot infer anything from `nil`, hence we need to add back the type restriction.

The help now looks like this:

```console hl_lines="8"
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication --help
Usage: ./bin/myapplication [OPTIONS] [NAME]

Arguments:
  NAME

Options:
  --help  Show this message and exit.
```

And it sets the correct default value:

```console
$ ./bin/myapplication
Hello world!
$ ./bin/myapplication Alice
Hello Alice
```
