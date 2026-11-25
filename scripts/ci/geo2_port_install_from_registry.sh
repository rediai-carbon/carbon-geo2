#!/bin/bash
# Install carbon-geo2 from carbon-vcpkg-registry into an isolated prefix.
# Requires: FENRIS_VCPKG_ROOT (e.g. /work/vcpkg), /reg triplet overlay (carbon-vcpkg-registry checkout).
set -euo pipefail
export PATH_TO_VCPKG_ROOT="${FENRIS_VCPKG_ROOT:?set FENRIS_VCPKG_ROOT}"
export VCPKG_ROOT="$PATH_TO_VCPKG_ROOT"
REG="${GEO2_REGISTRY_SHA:-ad5c5f2f615e45e91b476ca685b8ef9818431e2c}"
OVERLAY_PORTS="${GEO2_OVERLAY_PORTS:-}"
rm -rf /tmp/geo2-port /tmp/geo2-port-build
mkdir -p /tmp/geo2-port
cat > /tmp/geo2-port/vcpkg.json <<'EOF'
{
  "name": "geo2-port-consumer",
  "version": "1.0.0",
  "dependencies": ["carbon-geo2"]
}
EOF
cat > /tmp/geo2-port/vcpkg-configuration.json <<EOF
{
  "default-registry": {
    "kind": "git",
    "baseline": "d186940b2f0c4e8e5b4ff804af57d2a26fbfa091",
    "repository": "https://github.com/microsoft/vcpkg.git"
  },
  "registries": [
    {
      "kind": "git",
      "baseline": "${REG}",
      "reference": "${REG}",
      "repository": "https://github.com/rediai-carbon/carbon-vcpkg-registry.git",
      "packages": ["carbon-geo2","carbon-math","carbon-core","ccp-debug-info","tracy","python3","zlib"]
    }
  ]
}
EOF
echo 'cmake_minimum_required(VERSION 3.16); project(geo2_port_consumer LANGUAGES CXX); find_package(carbon-geo2 CONFIG REQUIRED)' > /tmp/geo2-port/CMakeLists.txt
CMAKE_EXTRA=()
if [ -n "$OVERLAY_PORTS" ]; then
  CMAKE_EXTRA+=("-DVCPKG_OVERLAY_PORTS=${OVERLAY_PORTS}")
fi
GEO2_EXPECT_REF="${GEO2_EXPECT_REF:-72d8992f2faf2dc65a8a925b952d59bc4368fd8e}"
cmake -S /tmp/geo2-port -B /tmp/geo2-port-build -G Ninja -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_TOOLCHAIN_FILE="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake" \
  -DVCPKG_TARGET_TRIPLET=x64-linux-release -DVCPKG_HOST_TRIPLET=x64-linux-release \
  -DVCPKG_OVERLAY_TRIPLETS="${FENRIS_REGISTRY_ROOT:?}/triplets" \
  -DVCPKG_CHAINLOAD_TOOLCHAIN_FILE="${FENRIS_REGISTRY_ROOT}/toolchains/x64-linux-carbon.cmake" \
  "${CMAKE_EXTRA[@]}" 2>&1 | tee /tmp/geo2-port-configure.log
grep -E "carbon-geo2-${GEO2_EXPECT_REF}|carbon-geo2.git" /tmp/geo2-port-configure.log
PREFIX=/tmp/geo2-port-build/vcpkg_installed/x64-linux-release
SO=$(find "$PREFIX" -name '_geo2.so' | head -n 1)
PY=$(find "$PREFIX" -type f -name 'python3.12' | head -n 1)
test -n "$SO" && test -n "$PY"
PYTHONPATH="$(dirname "$SO")" "$PY" "${GEO2_REPO_ROOT:?}/examples/installed_consumer.py"
echo GEO2_PORT_CONSUMER_OK