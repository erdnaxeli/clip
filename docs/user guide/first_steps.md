# First steps

Let's do a hello world like app. We will change `src/mycommand.cr` to:

```Crystal hl_lines="1 6-10 13-18 20-24"
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

  def self.hello(name)
    puts "Hello #{name}"
  end
end

Mycommand.run
```

You can build and run the app, it will work as expected:
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

We will now look at every block of code.

## Mapping a type

```Crystal hl_lines="2"
struct Command
  include Clip::Mapper

  getter name : String
end
```

**Clip** work by including `Clip::Mapper` inside a type, a class or a struct.
By including this module, a macro is executed and generate a constructor, the method `#parse` we used earlier, and the help.
It works by analysing the type's attributes to find what option and arguments will be parsed.
We said it _maps_ the type definition to the expected CLI parameters, hence the name "Mapper".

The advantage is that you get a totally valid type, which guarantees you
type safety at compilation and completion when writing code (if your editor supports it). 

Here **Clip** detected that we need one argument named `NAME`.

!!! tip
    A class is allocated on the heap and passed by reference while a struct is allocated on the stack and passed by value.
    Hence structs are better suited for read only object.
    
    In this tutorial we will only use structs as we will never need to edit the
    object, but you can use classes as well.

## Parsing the user input

```Crystal hl_lines="2"
begin
  command = Command.parse
rescue ex : Clip::Error
  puts ex
  return
end
```

As said before, the macro creates a `#parse` method.
It accepts an array of strings, and defaults to `ARGV`.

This method act like a constructor.
It tries to parse the input, and on success it returns a new object.

But there are two other cases:

* on user input failure, it raises an error
* if the user use the special flag `--help`, it returns a special object

## Catching user input error

```Crystal hl_lines="3 4"
begin
  command = Command.parse
rescue ex : Clip::Error
  puts ex
  return
end
```

If the user made a mistake, by example by using an option not defined or not giving a required argument, the `#parse` method will raise an exception.

For now you only need to know two facts:

* the exception always inherits from `Clip::Error`
* the exception's message is a preformatted error message

This means that you can just rescue `Clip::Error` and puts the rescued exception to show the user a nice error message, as we just did.
We will see later in this tutorial exactly what exceptions can be raised and how you can use them to format your own error messages.

## The help case

```Crystal
if command.is_a?(Clip::Mapper::Help)
  puts command.help
else
  hello(command.name)
end
```

The help option is a special case that needs a special treatment.
When the user use `--help`, it does not expect to get an error because `NAME` is required and was not provided.
But `NAME` _is_ indeed required, and we cannot return a `Command` instance as the Crystal compiler will complain that `@name` was not initialized (and we don't want to initialize it with a random or arbitrary value).

The choice made by **Clip** is to return a instance of a special type `Command::Help`.
This type was generated when including the `Clip::Mapper` module and has two properties:

1. it inherits from `Clip::Mapper::Help`, which will be useful when we will look at commands
2. it provide a method `#help` that return the generated help message

That why we do this first check using `#is_a?`, and we print the help if requested by the user.
In the `else` clause the compiler knows that our object is an instance of `Command`, and we can use its "name" attribute.

## Options, arguments and parameters

So far we used those tree words.
We said that `NAME` is an argument, that `--help` is an option, and we mentioned _CLI parameters_. But what are they?

!!! note
    All that will follow are just conventions.
    They are more often than not respected, but some command may have different conventions, like `tar` which accepts options with hypens.

### CLI Parameters

A _CLI parameter_ or just _parameter_ is anything given after the executable's name when executing a command. So in the command `ls -lh /tmp`, the parameters are `-lh` and `/tmp`.

### Options

An _option_ is a specific type of parameter that must be named.
It can have a value or not, it can be long or short, and if short it can be _concatenated_.

```console
$ somecommand --name=Alice -lg --file somefile
```

In this fictitious command there are 4 options:

* `--name`, with a value `Alice`
* `-l`, without value
* `-g`, without value
* `--file`, with a value `somefile`

### Arguments

An _argument_ is a specific type of parameter that must not be named.

In our command `mycommand` the usage says: `./bin/mycommand [OPTIONS] NAME`. `NAME` is an argument, so you don't have to do `./bin/mycommand --name Alice` but instead just `./bin/mycommand Alice` works.
