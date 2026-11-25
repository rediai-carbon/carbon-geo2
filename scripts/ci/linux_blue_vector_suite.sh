#!/bin/bash
# Full Geo2 vector unittest module through the accepted Blue exefile runtime.
# Prerequisites (Fenris Linux lane): fe-linux-fresh volume with build-registry Blue prefix,
# carbon-linux-gcc-buildenv:fe1, FENRIS_VCPKG_ROOT, FENRIS_REGISTRY_ROOT, FENRIS_BLUE_BUILD=/work/build-registry.
set -euo pipefail
GEO2_REPO_ROOT="${GEO2_REPO_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$SCRIPT_DIR/geo2_port_install_from_registry.sh"
BLUE_PREFIX="${FENRIS_BLUE_PREFIX:-/work/build-registry/vcpkg_installed/x64-linux-release}"
BUILD="${FENRIS_BLUE_BUILD:-/work/build-registry}"
GEO2_SO=/tmp/geo2-port-build/vcpkg_installed/x64-linux-release/lib/_geo2.so
install -m 0644 "$GEO2_SO" "$BLUE_PREFIX/lib/_geo2.so"
export LD_LIBRARY_PATH="$BUILD:$BLUE_PREFIX/lib"
export PYTHONPATH="$BUILD:$BLUE_PREFIX/lib:$BLUE_PREFIX/bin:$BLUE_PREFIX/bin/python:$BLUE_PREFIX/lib/python3.12:${GEO2_REPO_ROOT}/python"
cp -f "$BLUE_PREFIX/tools/carbon-exefile/exefile" "$BUILD/exefile"
"$BUILD/exefile" /nocrashreportupload /buildflavor=release /py -c '
import sys, blue, geo2, importlib.util
spec = importlib.util.find_spec("_geo2")
assert spec and spec.origin and "build-registry" in spec.origin
v = geo2.VectorD(1.0, 2.0, 3.0)
assert tuple(v / 2.0) == (0.5, 1.0, 1.5)
libpy = {line.split()[-1] for line in open("/proc/self/maps") if "libpython" in line}
assert len(libpy) == 1
print("GEO2_BLUE_LOAD", spec.origin)
print("LIBPYTHON", sorted(libpy)[0])
'
set +e
"$BUILD/exefile" /nocrashreportupload /buildflavor=release /py "$GEO2_REPO_ROOT/python/geo2/test/test_geo2Vector3.py" 2>&1 | tee /tmp/geo2-vector-unittest.log
UT_EXIT=${PIPESTATUS[0]}
set -e
grep -E '^OK|^FAILED' /tmp/geo2-vector-unittest.log
test "$UT_EXIT" -eq 0
grep -q '^OK' /tmp/geo2-vector-unittest.log
echo GEO2_BLUE_VECTOR_SUITE_OK