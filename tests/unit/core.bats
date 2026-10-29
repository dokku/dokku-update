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

setup_apt_stubs() {
  mkdir -p "$BATS_TEST_TMPDIR/bin"
  cat >"$BATS_TEST_TMPDIR/bin/apt-get" <<'STUB'
#!/usr/bin/env bash
for arg in "$@"; do
  if [[ "$arg" == "update" ]]; then
    echo "stub-apt-update-start"
    sleep "${STUB_APT_SLEEP:-0}"
    echo "stub-apt-update-end"
    exit "${STUB_APT_EXIT:-0}"
  fi
done
exit 0
STUB
  cat >"$BATS_TEST_TMPDIR/bin/dokku" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
  chmod +x "$BATS_TEST_TMPDIR/bin/apt-get" "$BATS_TEST_TMPDIR/bin/dokku"
}

skip_unless_apt_distro() {
  local distro=""
  if [[ -f /etc/os-release ]]; then
    distro="$(. /etc/os-release && echo "$ID")"
  fi
  if [[ "$distro" != "debian" ]] && [[ "$distro" != "ubuntu" ]]; then
    skip "requires a debian or ubuntu host"
  fi
}

@test "(core) dokku-update help includes output-delay flag" {
  run bash -c "dokku-update help"
  echo "output: $output"
  echo "status: $status"
  [[ "$output" == *"--output-delay"* ]]
}

@test "(core) dokku-update run help includes output-delay flag" {
  run bash -c "dokku-update run --help"
  echo "output: $output"
  echo "status: $status"
  [[ "$output" == *"--output-delay"* ]]
  [[ "$output" == *"DOKKU_UPDATE_OUTPUT_DELAY"* ]]
}

@test "(core) dokku-update run --output-delay without value fails" {
  run bash -c "dokku-update run --output-delay"
  echo "output: $output"
  echo "status: $status"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"requires a value in seconds"* ]]
}

@test "(core) dokku-update run --output-delay invalid value fails" {
  run bash -c "dokku-update run --output-delay abc"
  echo "output: $output"
  echo "status: $status"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Invalid output delay"* ]]
}

@test "(core) dokku-update run with invalid DOKKU_UPDATE_OUTPUT_DELAY fails" {
  run bash -c "DOKKU_UPDATE_OUTPUT_DELAY=abc dokku-update run"
  echo "output: $output"
  echo "status: $status"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"Invalid output delay"* ]]
}

@test "(core) dokku-update run hides fast apt-get update output" {
  skip_unless_apt_distro
  setup_apt_stubs
  run bash -c "PATH='$BATS_TEST_TMPDIR/bin:$PATH' STUB_APT_SLEEP=0 dokku-update run --system-update --skip-plugins --skip-rebuild --output-delay 5"
  echo "output: $output"
  echo "status: $status"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *"stub-apt-update-start"* ]]
  [[ "$output" != *"taking longer than"* ]]
}

@test "(core) dokku-update run streams slow apt-get update output" {
  skip_unless_apt_distro
  setup_apt_stubs
  run bash -c "PATH='$BATS_TEST_TMPDIR/bin:$PATH' STUB_APT_SLEEP=3 dokku-update run --system-update --skip-plugins --skip-rebuild --output-delay 1"
  echo "output: $output"
  echo "status: $status"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"apt-get update is taking longer than 1 seconds"* ]]
  [[ "$output" == *"stub-apt-update-start"* ]]
  [[ "$output" == *"stub-apt-update-end"* ]]
}

@test "(core) dokku-update run respects DOKKU_UPDATE_OUTPUT_DELAY" {
  skip_unless_apt_distro
  setup_apt_stubs
  run bash -c "PATH='$BATS_TEST_TMPDIR/bin:$PATH' STUB_APT_SLEEP=3 DOKKU_UPDATE_OUTPUT_DELAY=1 dokku-update run --system-update --skip-plugins --skip-rebuild"
  echo "output: $output"
  echo "status: $status"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"apt-get update is taking longer than 1 seconds"* ]]
  [[ "$output" == *"stub-apt-update-start"* ]]
  [[ "$output" == *"stub-apt-update-end"* ]]
}

@test "(core) dokku-update run shows fast apt-get update output on failure" {
  skip_unless_apt_distro
  setup_apt_stubs
  run bash -c "PATH='$BATS_TEST_TMPDIR/bin:$PATH' STUB_APT_SLEEP=0 STUB_APT_EXIT=100 dokku-update run --system-update --skip-plugins --skip-rebuild --output-delay 5"
  echo "output: $output"
  echo "status: $status"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"stub-apt-update-start"* ]]
  [[ "$output" != *"taking longer than"* ]]
}
