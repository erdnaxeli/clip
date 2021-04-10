# Nilable arguments

**Clip** specify in the help message if an argument is required or not, like this:

```console
  NAME  [required]
```

or

```console
  NAME  [default: Barbara]
```

If you don't want any message, you can declare the attribute's type nilable and set a default value `nil`:

```Crystal hl_lines="9 10"
require "clip"

module Mycommand
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

Mycommand.run
```

!!! Tip
    As our attribute does have a default value we need to explicitly add the `Clip::Argument` annotation.

Now the help looks like this:

```console hl_lines="8"
$ shards build
Dependencies are satisfied
Building: mycommand
$ ./bin/mycommand --help
Usage: ./bin/mycommand [OPTIONS] [NAME]

Arguments:
  NAME

Options:
  --help  Show this message and exit.
```

And it set the correct default value:

```console
$ ./bin/mycommand
Hello world!
$ ./bin/mycommand Alice
Hello Alice
```
