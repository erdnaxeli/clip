# Contributing

Feel free to contribute to **Clip**.

If you spot a bug, you can [open a pull request](https://github.com/erdnaxeli/clip/pulls) to fix it.
If you want to contribute but are not sure about how to do it, just [open an issue](https://github.com/erdnaxeli/clip/issues) to talk discuss about it.

Here are some tips to develop on **Clip**, assuming you have already cloned the repository.

## Install the dependencies

Don't forget to install the dependencies.
There is only one so far, and it is a dev one, but it will be useful.

```console
$ shards install
Resolving dependencies
Fetching https://github.com/crystal-ameba/ameba.git
Installing ameba (0.14.2)
Postinstall of ameba: make bin && make run_file
```

## Develop your fix or feature

Always remember to commit your modification on a separated branch.

The majority of the **Clip** features are done by macros.
Macros look like Crystal code, but they actually use a different language that is interpreted at compilation time by the compiler.
The code is not easy to read, don't hesitate to ask for help!

You may want to read the [reference about macros](https://crystal-lang.org/reference/syntax_and_semantics/macros/index.html) and the [macro module documentation](https://crystal-lang.org/api/1.0.0/Crystal/Macros.html).

## Write and run the tests

Whether you fixed a bug or developed a new feature, you need to write a test to test the new behavior.

Then run the tests:

```console
$ crystal spec
........................................................................................................................................

Finished in 5.95 milliseconds
136 examples, 0 failures, 0 errors, 0 pending
```

## Run static code analysis

Ameba provides some hints about the code, to prevent wrong code constructions.

Run it with:

```
$ ./bin/ameba
Inspecting 16 files

................

Finished in 279.16 milliseconds
17 inspected, 0 failure
```

!!! Warning
    There is currently an [open issue](https://github.com/crystal-ameba/ameba/issues/224) on Ameba about `Lint/ShadowingOuterLocalVar`, you can skip this failure.

## Open a pull request

Your code is now done, congrats!
Your can open a pull request, I will try to at it quickly :)
