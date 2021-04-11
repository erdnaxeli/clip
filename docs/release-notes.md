# Release notes

## 0.x

### 0.2.4

* Fix arguments parsing order to respect the idx instruction
* Support `--help` with nested command
* Support for `name: nil` with `#help`
* Fix array arguments in usage line
* Fix #help generated by .add_commands to support `nil` and the command's doc
* Add a `#parse(String)` method

### 0.2.3

* fix the error message when an argument's value is invalid

### 0.2.2

* fix errors' message
* the generated subclass `Help` now inherits from `Clip::Mapper::Help`
* fix a bug when calling a command with subcommands without specifying any command
* fix the help usage for commands (note that the subclass `Help` is not a singleton anymore)

### 0.2.1

* all errors inherit from `Clip::Error`
* all errors have a correct message
* document the `--help` flag in the help message
* add a command `help` when there is commands

### 0.1.0

first public version