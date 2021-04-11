# Clip

---

**Documentation**: [https://erdnaxeli.github.io/clip/](https://erdnaxeli.github.io/clip)

**Source code**: [https://github.com/erdnaxeli/clip/](https://github.com/erdnaxeli/clip)

---

Clip is a library for building CLI or CLI-like [Crystal](https://crystal-lang.org) applications.
_A CLI-like application_ means any application that interacts with the user in a CLI style, like IRC bots.

The major features of Clip are:

* **Easy to write**: All you need to write is a class (or struct). No new DSL to learn, and compilation time type validation.
* **Easy to use**: Make user friendly applications with standard behaviors and automatic error and help messages.
* **You are in control**: No code automatically executed for you, no messages printed to stdout. You do what you want, when you want.

## Requirements

Crystal 0.36.0 or later.
Clip depends only on the standard library.

## Installation

Add the dependency to your `shard.yml`:

```Yaml
dependencies:
  clip:
    github: erdnaxeli/clip
```

Run `shards install`.

## Example

Create a file named `command.cr`:

```Crystal
require "clip"

struct Command
  include Clip::Mapper

  getter name : String
end

begin
  command = Command.parse
rescue ex : Clip::Error
  puts ex
  exit
end

if command.is_a?(Clip::Mapper::Help)
  puts command.help
else
  puts "Hello #{command.name}"
end
```

Build it and run it:

```console
$ crystal build command.cr
$ ./command
Error:
  argument is required: NAME
$ ./command --help
Usage: ./command [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --help  Show this message and exit.
$ ./command Alice
Hello Alice
```

## Advanced example

Let's do a more advanced, with some commands.

```Crystal hl_lines="6-9 32 33 35"
require "clip"

abstract struct Command
  include Clip::Mapper

  Clip.add_commands({
    "hello"   => HelloCommand,
    "goodbye" => GoodbyeCommand,
  })

  getter name : String
end

struct HelloCommand < Command
  include Clip::Mapper
end

struct GoodbyeCommand < Command
  include Clip::Mapper

  getter sad = false
end

begin
  command = Command.parse
rescue ex : Clip::Error
  puts ex
  exit
end

case command
when HelloCommand
  puts "Hello #{command.name}"
when GoodbyeCommand
  if command.sad
    puts "Goodbye #{command.name} :'("
  else
    puts "Goodbye #{command.name}"
  end
when Clip::Mapper::Help
  puts command.help
end
```

It adds two commands: "hello" and "goodbye".

```console
$ crystal build command.cr
$ ./command
Error: you need to provide a command.
$ ./command help
Usage: ./command COMMAND [ARGS]...

Commands:
  hello
  goodbye
  help     Show this message and exit.
$ ./command hello --help
Usage: ./command hello [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --help  Show this message and exit.
$ ./command hello Alice
Hello Alice
$ ./command goodbye --help
Usage: ./command goodbye [OPTIONS] NAME

Arguments:
  NAME  [required]

Options:
  --sad / --no-sad  [default: false]
  --help            Show this message and exit.
$ ./command goodbye Alice
Goodbye Alice
$ ./command goodbye --sad Alice
Goodbye Alice :'(
```

--8<-- "includes/abbreviations.md"
