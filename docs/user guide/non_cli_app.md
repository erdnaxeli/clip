# Non CLI applications

In this whole documentation we used a CLI application to demonstrate the capabilities of **Clip**.
But one goal of **Clip** is to work as well for a CLI application than for an application which interacts with users in a text way and want to use options, arguments or commands.

Example of such applications are REPL or text bots (like IRC bots).

Let's build a very simple REPL:

```Crystal
module Myapplication
  VERSION = "0.1.0"

  def self.run
    loop do
      print "> "
      case gets
      when "hello"
        self.hello
      when "exit"
        return
      else
        puts "Unknown command."
      end
    end
  end

  def self.hello
    puts "Hello, world!"
  end
end

Myapplication.run
```

It does not do much, but it does something:

```console
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication
> help
Unknown command.
> hello
Hello, world!
> exit
```

Now we would like to let the user specify the person to greet.
We could try to parse the input when it starts with "hello", and accept one argument.
Then we may want to add another feature that could be enabled but would be disabled by default, something like… an option.
And then we will probably want to add some others commands, and we will need an help command so the user could known which commands are available and how to use them.

You have probably guessed it yet: we want to interact with our REPL like we would do with a CLI application.
So why writing all this mechanism by ourself?
Unlike most of the CLI application libraries, **Clip** was built from the begining with this use case in mind.
That's why **Clip** _never_ prints anything by itself.
You are in control, because your output may not be `STDOUT` but instead an IRC channel or anything else.

Let's use **Clip** to build a nicer REPL with all that we learned:

```Crystal
require "process"

require "clip"

module Myapplication
  VERSION = "0.1.0"

  @[Clip::Doc("Greet a person.")]
  abstract struct Command
    include Clip::Mapper

    Clip.add_commands({
      "hello"   => HelloCommand,
      "goodbye" => GoodbyeCommand,
      "exit"    => ExitCommand,
    })
  end

  abstract struct GreetCommand < Command
    @[Clip::Doc("The name of the person to greet.")]
    getter name : String
  end

  @[Clip::Doc("Say hello to someone.")]
  struct HelloCommand < GreetCommand
    include Clip::Mapper

    @[Clip::Doc("Repeat the message many times.")]
    getter repeat = 1
  end

  @[Clip::Doc("Say goodbye to someone.")]
  struct GoodbyeCommand < GreetCommand
    include Clip::Mapper

    @[Clip::Option("-y", "--yell")]
    @[Clip::Doc("Activate YELLING.")]
    getter yell : Bool? = nil
  end

  @[Clip::Doc("Exit the program.")]
  struct ExitCommand < Command
    include Clip::Mapper
  end

  def self.run
    loop do
      print "> "
      if input = gets
        begin
          command = Command.parse(input)
        rescue ex : Clip::Error
          puts ex
          next
        end

        case command
        when Clip::Mapper::Help
          puts command.help(nil)
        when HelloCommand
          hello(command.name, command.repeat)
        when GoodbyeCommand
          goodbye(command.name, command.yell)
        when ExitCommand
          return
        end
      else
        # we get here if the user types ^D
        puts
        return
      end
    end
  end

  def self.hello(name, repeat)
    repeat.times { puts "Hello, #{name}!" }
  end

  def self.goodbye(name, yell)
    msg = "Goodbye, #{name}!"

    if yell
      puts msg.upcase
    else
      puts msg
    end
  end
end

Myapplication.run
```

!!! Tip
    We could parse the `input` string using [`Process.parse_arguments`](https://crystal-lang.org/api/1.0.0/Process.html#parse_arguments(line:String):Array(String)-class-method), but the `#parse` method provides a shortcut and accepts a string.
    Internally it uses the exact same method from the `Process` class.

Now we have options and arguments support, beautiful help messages, and error handling!

```console
$ shards build
Dependencies are satisfied
Building: myapplication
$ ./bin/myapplication
> help
Usage: COMMAND [ARGS]...

Greet a person.

Commands:
  hello    Say hello to someone.
  goodbye  Say goodbye to someone.
  exit     Exit the program.
  help     Show this message and exit.
> hello --help
Usage: hello [OPTIONS] NAME

Say hello to someone.

Arguments:
  NAME  The name of the person to greet.  [required]

Options:
  --repeat INTEGER  Repeat the message many times.  [default: 1]
  --help            Show this message and exit.
> goodbye --help
Usage: goodbye [OPTIONS] NAME

Say goodbye to someone.

Arguments:
  NAME  The name of the person to greet.  [required]

Options:
  -y, --yell  Activate YELLING.
  --help      Show this message and exit.
> hello --repeat 2 Alice
Hello, Alice!
Hello, Alice!
> goodbye -y Alice
GOODBYE, ALICE!
> hello -y Alice
Error:
  no such option: -y
> goodbye
Error:
  argument is required: NAME
> exit
$
```

--8<-- "includes/abbreviations.md"
