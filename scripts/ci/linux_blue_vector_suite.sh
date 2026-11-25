#!/bin/bash
# Full Geo2 vector unittest module through the accepted Blue exefile runtime (Fenris lane).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GEO2_REPO_ROOT="${GEO2_REPO_ROOT:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
bash "$SCRIPT_DIR/geo2_port_install_from_registry.sh"
BLUE_PREFIX="${FENRIS_BLUE_PREFIX:-/work/build-registry/vcpkg_installed/x64-linux-release}"
BUILD="${FENRIS_BLUE_BUILD:-/work/build-registry}"
GEO2_SO=/tmp/geo2-port-build/vcpkg_installed/x64-linux-release/lib/_geo2.so
STAGE="${FENRIS_GEO2_STAGE_DIR:-/tmp/fenris-geo2-blue-stage}"
mkdir -p "$STAGE/lib"
install -m 0644 "$GEO2_SO" "$STAGE/lib/_geo2.so"
if [ "${FENRIS_GEO2_INSTALL_IN_BLUE_PREFIX:-0}" = "1" ]; then
  install -m 0644 "$GEO2_SO" "$BLUE_PREFIX/lib/_geo2.so"
fi
export LD_LIBRARY_PATH="$BUILD:$BLUE_PREFIX/lib:$STAGE/lib"
export PYTHONPATH="$BUILD:$BLUE_PREFIX/lib:$BLUE_PREFIX/bin:$BLUE_PREFIX/bin/python:$BLUE_PREFIX/lib/python3.12:${STAGE}/lib:${GEO2_REPO_ROOT}/python"
cp -f "$BLUE_PREFIX/tools/carbon-exefile/exefile" "$BUILD/exefile"
"$BUILD/exefile" /nocrashreportupload /buildflavor=release /py -c '
import sys, blue, geo2, importlib.util
spec = importlib.util.find_spec("_geo2")
assert spec and spec.origin
assert "fenris-geo2-blue-stage" in spec.origin or "build-registry" in spec.origin
v = geo2.VectorD(1.0, 2.0, 3.0)
assert tuple(v / 2.0) == (0.5, 1.0, 1.5)
libpy = {line.split()[-1] for line in open("/proc/self/maps") if "libpython" in line}
assert len(libpy) == 1
print("GEO2_BLUE_LOAD", spec.origin)
print("LIBPYTHON", sorted(libpy)[0])
'
UT_LOG=/tmp/geo2-vector-unittest.log
set +e
"$BUILD/exefile" /nocrashreportupload /buildflavor=release /py "$GEO2_REPO_ROOT/python/geo2/test/test_geo2Vector3.py" 2>&1 | tee "$UT_LOG"
UT_EXIT=${PIPESTATUS[0]}
set -e
grep -E '^Ran |^OK|^FAILED|skipped' "$UT_LOG" || true
if [ "$UT_EXIT" -ne 0 ]; then
  echo "GEO2_VECTOR_UNITTEST_EXIT=$UT_EXIT"
  exit "$UT_EXIT"
fi
grep -q '^OK' "$UT_LOG"
echo GEO2_BLUE_VECTOR_SUITE_OK