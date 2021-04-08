# Setup

This tutorial will cover step by step all the features of **Clip**.
You need a working Crystal environment.

First, you need a new project:

```console
$ crystal init app mycommand
    create  /home/erdnaxeli/bacasable/mycommand/.gitignore
    create  /home/erdnaxeli/bacasable/mycommand/.editorconfig
    create  /home/erdnaxeli/bacasable/mycommand/LICENSE
    create  /home/erdnaxeli/bacasable/mycommand/README.md
    create  /home/erdnaxeli/bacasable/mycommand/.travis.yml
    create  /home/erdnaxeli/bacasable/mycommand/shard.yml
    create  /home/erdnaxeli/bacasable/mycommand/src/mycommand.cr
    create  /home/erdnaxeli/bacasable/mycommand/spec/spec_helper.cr
    create  /home/erdnaxeli/bacasable/mycommand/spec/mycommand_spec.cr
Initialized empty Git repository in /home/erdnaxeli/bacasable/mycommand/.git/
```

Then you have to add **Clip** as a dependency in `shards.yml`:
```Yaml
dependencies:
  clip:
    github: erdnaxeli/clip
```

For a real project you should add a constraint on the version, but we will skip it here.
You can see the latest versions on the [releases page](https://github.com/erdnaxeli/clip/releases).

You can now build the app and run it:

```console
$ shards build
Resolving dependencies
Fetching https://github.com/erdnaxeli/clip.git
Installing clip (0.2.2)
Writing shard.lock
Building: mycommand
$ ./bin/mycommand
$
```

In the next step we will do a first simple application.
