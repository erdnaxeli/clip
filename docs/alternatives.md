# Alternatives, inspirations and comparisons

**Clip** is not the only library to parse CLI parameters.
Here are some alternatives and inspirations.

## <a href="https://typer.tiangolo.com" class="external-link" target="_blank">Typer</a>

> Typer is a library for building CLI applications that users will love using and developers will love creating.

Typer is actually a Python library and an awesome project!
It inspired a lot **Clip**, whether for the idea of using type restrictions, the general behavior of the lib (what to consider an option or an argument, the help message), or even this documentation.

## <a href="https://crystal-lang.org/api/1.0.0/OptionParser.html" class="external-link" target="_blank">OptionParser</a>

> `OptionParser` is a class for command-line options processing.

It works by using a specific DSL to react to options or arguments during the parsing.

## <a href="https://github.com/jwaldrip/admiral.cr" class="external-link" target="_blank">Admiral.cr</a>

> A robust DSL for writing command line interfaces

Admiral provides an easy way to define command using a user defined type and a DSL.

## <a href="https://github.com/mrrooijen/commander" class="external-link" target="_blank">Commander</a>

> Command-line interface builder for the Crystal programming language.

Commander provides a DSL to declare and use options, arguments, and commands.

## <a href="https://github.com/j8r/clicr" class="external-link" target="_blank">Clicr</a>

> A simple declarative command line interface builder.

Unlike to others presented libraries (and **Clip**), Clicr is declarative: you call the library with a NamedTuple describing exactly what options, arguments and command you want.

--8<-- "includes/abbreviations.md"
