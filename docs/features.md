# Features

## Static typing

**Clip** uses a user defined type, struct or class, to infer what options and arguments should be parsed.

The object returned by the **Clip** parsing method is just an instance of this type, hence you benefit from the type validation at compilation time.

## No DSL to learn

There is no new DSL to learn to build applications with **Clip**.

You want to add a string option? Just add an attribute with a type `String`.

You want the option to have a default value? Just add a default value to the attribute.

You already know how to do it.

## User friendly

**Clip** allows you to build user friendly applications that respect standard behaviors.
Anything you expect from a CLI application should work with **Clip** too: short and long options, flags, arguments, default values, multiple values, standard help messages, and many more.

## Not a CLI application framework

**Clip** is about parsing CLI-like user input, but is not a framework to build CLI applications.

It means that **Clip** does not run your application code for you, does not print anything for you, and can read the user input from any array of strings or just any string, not only `ARGV`.

Not running your application code for you means that you are free to architecture you code as you like.
Your command's code can take the parsed options and arguments as a parameter, and others parameters too, because _you_ run it yourself, **Clip** does not.

Not printing anything for you means that you can send errors and help messages to any medium, being `STDOUT`, a socket, or anything else.

Reading the user input not only from `ARGV` means that you can use **Clip** to build applications that are not _CLI applications_.
You can receive the user input from an HTTP call, an IRC message, a REPL, or whatever you want.

## Efficient

**Clip** uses your type definition to write a parser and build the help message for each command.
The parsers and the help messages are built at compilation time, which enabled **Clip** to have a minimal overhead at runtime.

## Tested

The **Clip** repository contains 136 tests covering all its features, and all the documentation examples can be run "as is".

--8<-- "includes/abbreviations.md"
