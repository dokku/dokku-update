# dokku-update

[![Build Status](https://github.com/dokku/dokku-update/workflows/CI/badge.svg)](https://github.com/dokku/dokku-update/actions?query=workflow%3ACI)

Updates Dokku & its dependencies, all enabled plugins and rebuilds all Dokku apps. Optionally installs all other system updates.

## Commands

```shell
dokku-update run [-s] # Triggers the update process; when invoked with optional -s argument, all system updates will be installed
dokku-update help       # Shows help information
dokku-update version    # Shows version
```
