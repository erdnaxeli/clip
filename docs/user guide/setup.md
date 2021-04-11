# Setup

This tutorial will cover step by step all the features of **Clip**.
We will build a project together to explore them.
You need a working Crystal environment.

First, we create a new project:

```console
$ crystal init app myapplication
    create  /home/erdnaxeli/bacasable/myapplication/.gitignore
    create  /home/erdnaxeli/bacasable/myapplication/.editorconfig
    create  /home/erdnaxeli/bacasable/myapplication/LICENSE
    create  /home/erdnaxeli/bacasable/myapplication/README.md
    create  /home/erdnaxeli/bacasable/myapplication/.travis.yml
    create  /home/erdnaxeli/bacasable/myapplication/shard.yml
    create  /home/erdnaxeli/bacasable/myapplication/src/myapplication.cr
    create  /home/erdnaxeli/bacasable/myapplication/spec/spec_helper.cr
    create  /home/erdnaxeli/bacasable/myapplication/spec/myapplication_spec.cr
Initialized empty Git repository in /home/erdnaxeli/bacasable/myapplication/.git/
```

Then we add **Clip** as a dependency in `shards.yml`:
```Yaml
dependencies:
  clip:
    github: erdnaxeli/clip
```

In a real project you should add a constraint on the version, but we will skip it here.
You can see the latest version in the header of this documentation or on the [releases page](https://github.com/erdnaxeli/clip/releases).

We can now build the app and run it:

```console
$ shards build
Resolving dependencies
Fetching https://github.com/erdnaxeli/clip.git
Installing clip (0.2.2)
Writing shard.lock
Building: myapplication
$ ./bin/myapplication
$
```

In the next step we will write a simple application.
