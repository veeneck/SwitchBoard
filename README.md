# SwitchBoard

Convenient scene management functions and extensions for SpriteKit projects. Goal is to include tools for:

- Loading and caching scenes from .sks files
- Group scenes together when similar assets need to be loaded / unloaded
- Add extensions like scene recording to SKScene
- Handle world and debug layers

## Status

In progress.

Not battle hardened and tested. Still useful though.

Not designed for full flexibility. Scope limited to my projects. I would say 90% could be easily reused.

## Dependencies

Needs the Particleboard framework to build. As of this writing, Particleboard is only included for easing functions, so a hard coded easing function could replace this. Subject to change.

## Documentation

Docs are located at [veeneck.github.io/SwitchBoard](http://veeneck.github.io/SwitchBoard) and are generated with [Jazzy](https://github.com/Realm/jazzy). The config file for the documentation is in the project as `config.yml`. Docs can be generated by running this command **in** the project directory:

jazzy --config {PATH_TO_REPOSITORY}/SwitchBoard/SwitchBoard/config.yml

**Note**: The output in the `config.yml` is hard coded to one computer. Edit the file and update the `output` flag to a valid location.
