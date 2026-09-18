#!/usr/bin/env bash
set -euo pipefail

# Dataform Core is built with Bazel, pinned via .bazelversion. Bazel itself, the
# Node.js toolchain, and every NPM dependency are downloaded and managed by
# Bazel, so the only prerequisite we need to add to the base image is Bazelisk
# (the standard Bazel launcher that reads .bazelversion).
BAZELISK_VERSION="v1.25.0"

if ! command -v bazel >/dev/null 2>&1; then
  echo "Installing Bazelisk ${BAZELISK_VERSION}..."
  tmp_bin="$(mktemp)"
  curl -fsSL -o "${tmp_bin}" \
    "https://github.com/bazelbuild/bazelisk/releases/download/${BAZELISK_VERSION}/bazelisk-linux-amd64"
  sudo install -m 0755 "${tmp_bin}" /usr/local/bin/bazel
  rm -f "${tmp_bin}"
fi

bazel version

# Install NPM dependencies from the frozen lockfile and build the CLI. This also
# warms the Bazel cache and downloads the pinned Bazel/Node toolchains so later
# builds, tests, and CLI invocations are fast.
bazel run @nodejs//:yarn -- --frozen-lockfile
bazel build //packages/@dataform/cli:bin
