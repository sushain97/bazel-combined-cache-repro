#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")" || exit

cache_dir=$(pwd)/cache
readonly cache_dir
rm -rf "$cache_dir"

echo "setup"
echo "====="
docker pull buchgr/bazel-remote-cache
docker kill bazel-remote-cache || true
docker run --rm -u 1000:1000 -v "$cache_dir":/data \
    -p 8888:8080 -p 9092:9092 --name bazel-remote-cache \
    buchgr/bazel-remote-cache &
trap "docker kill bazel-remote-cache >/dev/null" EXIT
curl --retry 10 --retry-delay 1 -sfS --retry-all-errors http://localhost:8888/status
echo

bazel=${BAZEL_PATH:-bazel}
bazel_flags=(
    --remote_cache=grpc://localhost:9092
    --experimental_build_event_upload_strategy=local
    --repository_cache="$cache_dir/bazel/repo-cache/"
    --disk_cache="$cache_dir/bazel/disk-cache/"
)

echo "initial build"
echo "============="
$bazel shutdown
$bazel clean
echo $RANDOM > input
$bazel build //:foo "${bazel_flags[@]}"
echo

echo "disk cache hit build"
echo "===================="
$bazel shutdown
$bazel clean
$bazel build //:foo "${bazel_flags[@]}"
echo

echo "remote cache hit build"
echo "======================"
$bazel shutdown
$bazel clean
rm -rf "$cache_dir/bazel/disk-cache"
rm -rf "$cache_dir/bazel/repo-cache"
$bazel build //:foo "${bazel_flags[@]}"
echo

echo "cache miss build"
echo "================"
$bazel shutdown
$bazel clean
rm -rf "$cache_dir/bazel/disk-cache"
rm -rf "$cache_dir/bazel/repo-cache"
echo $RANDOM > input
$bazel build //:foo "${bazel_flags[@]}"
echo
