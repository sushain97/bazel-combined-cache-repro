#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")" || exit

cache_dir=$(pwd)/cache
readonly cache_dir
rm -rf "$cache_dir"

echo "setup"
echo "====="
docker pull buchgr/bazel-remote-cache
docker stop bazel-remote-cache || true
docker run --rm -u 1000:1000 -v "$cache_dir":/data \
    -p 8888:8080 -p 9092:9092 --name bazel-remote-cache \
    buchgr/bazel-remote-cache &
curl --retry 10 --retry-delay 1 -sfS --retry-all-errors http://localhost:8888/status
echo

bazel=${BAZEL_PATH:-bazel}
bazel_flags=(
    --remote_cache=grpc://localhost:9092
    --remote_upload_local_results
    --remote_download_toplevel
    --nobuild_runfile_links
    --experimental_build_event_upload_strategy=local
)

echo "initial build"
echo "============="
$bazel shutdown
$bazel clean
$bazel build //:foo "${bazel_flags[@]}"
echo

echo "cached build"
echo "============="
$bazel shutdown
$bazel clean
$bazel build //:foo "${bazel_flags[@]}"
echo
