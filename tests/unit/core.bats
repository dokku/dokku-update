#!/usr/bin/env bats

@test "(core) dokku-update help" {
  run bash -c "dokku-update help | wc -l"
  echo "output: $output"
  echo "status: $status"
  [[ "$output" -ge 7 ]]
}
