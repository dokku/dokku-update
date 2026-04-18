#!/usr/bin/env bats

@test "(core) dokku-update help" {
  run bash -c "dokku-update help | wc -l"
  echo "output: $output"
  echo "status: $status"
  [[ "$output" -ge 6 ]]
}

@test "(core) dokku-update help includes dokku-version flag" {
  run bash -c "dokku-update help"
  echo "output: $output"
  echo "status: $status"
  [[ "$output" == *"--dokku-version"* ]]
}

@test "(core) dokku-update run help includes dokku-version flag" {
  run bash -c "dokku-update run --help"
  echo "output: $output"
  echo "status: $status"
  [[ "$output" == *"--dokku-version"* ]]
}

@test "(core) dokku-update run --dokku-version without value fails" {
  run bash -c "dokku-update run --dokku-version"
  echo "output: $output"
  echo "status: $status"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"requires a version argument"* ]]
}

@test "(core) dokku-update run --dokku-version with --system-update fails" {
  run bash -c "dokku-update run --dokku-version 0.29.0 --system-update"
  echo "output: $output"
  echo "status: $status"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"cannot be used with --system-update"* ]]
}

@test "(core) dokku-update run --dokku-version invalid format fails" {
  run bash -c "dokku-update run --dokku-version abc"
  echo "output: $output"
  echo "status: $status"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Invalid version format"* ]]
}
