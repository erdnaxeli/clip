# Features

## Static typing

**Clip** use a user defined type, a struct or a class, to infer what options and arguments should be parsed.

The object returned by the **Clip** parsing method is just an instance of this type, hence you benefit from the compilation time type validation.

## No DSL to learn

There is no new DSL to learn to build applications with **Clip**.

You want to add a string option? Just add an attribute and restrict its type to `String`.

You want to add a default value? Just add a default value to the attribute.

You already know how to do it.

## Standard behaviors

**Clip** allows you to build beautiful applications that respect standard behaviors.
Anything you expect from a CLI application should work with **Clip** too: short and long options, flags, arguments, default values, multiple values, standard help messages, and many more.

## Not a CLI application framework

**Clip** is about parsing CLI-like user input, but is not a framework to build CLI applications.

It means that **Clip** does not run your application code for you, does not print anything for you, and can read the user input from any array of strings, not only `ARGV`.

Not running your code application for you means that you are free to architecture you code as you like.
Your command's code can take the parsed options and arguments as a parameter, and anything else too, because _you_ run by yourself, **Clip** does not.

Not printing anything for you means that you can send errors and help messages to any medium, being a `STDOUT`, a socket, or anything else.

Reading the input from any array of strings means that you can use **Clip** to build applications that are not _CLI applications_.
You can receive the user input from an HTTP call, an IRC message, a REPL, or whatever you want.

## Efficient

**Clip** uses your type definition to write a parser and build the hel message.
The parser and the help messages are built at compilation time, which enabled **Clip** to have a minimal overhead at runtime.

## Tested

The **Clip** repository contains 136 tests covering all its features, and all the documentation examples can be run "as is".

--8<-- "includes/abbreviations.md"
