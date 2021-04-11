# Clip

Clip (CLI Parser) allows you to deserialize CLI parameters into an object, and
generates the help for you.

The goal of Clip is to let you in control.
It does not execute your code.
It does not print anything.
It can read from ARGV but also from any array of strings.
You choose what you want to do.

**Documentation**: <https://erdnaxeli.github.io/clip/>

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     clip:
       github: erdnaxeli/clip
   ```

2. Run `shards install`

## Usage

In a file command.cr:
```crystal
require "clip"

@[Clip::Doc("An example commmand.")]
struct Command
  include Clip::Mapper

  @[Clip::Doc("Enable some effect.")]
  getter effect = false

  @[Clip::Doc("The file to work on.")]
  getter file : String
end

begin
  command = Command.parse
rescue ex : Clip::ParsingError
  puts ex
  exit
end

case command
when Clip::Mapper::Help
  puts command.help
else
  if command.effect
    puts "Doing something with an effect on #{command.file}."
  else
    puts "Doing something on #{command.file}."
  end
end
```

Then:
```Shell
$ crystal build command.cr
$ ./command
Error:
  argument is required: FILE
$ ./command --help
Usage: ./command [OPTIONS] FILE

An example commmand.

Arguments:
  FILE  The file to work on.  [required]

Options:
  --effect / --no-effect  Enable some effect.  [default: false]
  --help                  Show this message and exit.
$ ./command myfile
Doing something on myfile.
$ ./command --effect myfile
Doing something with an effect on myfile.
```

## Contributing

1. Fork it (<https://github.com/erdnaxeli/clip/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Alexandre Morignot](https://github.com/erdnaxeli) - creator and maintainer
