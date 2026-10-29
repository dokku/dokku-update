# dokku-update

[![Build Status](https://github.com/dokku/dokku-update/workflows/CI/badge.svg)](https://github.com/dokku/dokku-update/actions?query=workflow%3ACI)

Updates Dokku & its dependencies, all enabled plugins and rebuilds all Dokku apps. Optionally installs all other system updates.

## Commands

```shell
dokku-update run [-s|--system-update] [--skip-plugins] [--parallel] [--skip-rebuild] [--dokku-version <version>] [--output-delay <seconds>] # Triggers the update process
dokku-update help                                                                                                                           # Shows help information
dokku-update version                                                                                                                        # Shows version
```

## Slow package index updates

On Debian and Ubuntu, `dokku-update run` refreshes the package index with `apt-get update` silently. If the refresh takes longer than 30 seconds, for example due to a slow package mirror, `dokku-update` starts streaming the `apt-get update` output so it is clear which repository is slow and that the process has not hung.

The delay can be changed with the `--output-delay <seconds>` flag, or by setting the `DOKKU_UPDATE_OUTPUT_DELAY` environment variable, for example in `/etc/default/dokku`. The flag takes precedence over the environment variable, and a value of `0` streams the output immediately.

```shell
dokku-update run --output-delay 10
```
