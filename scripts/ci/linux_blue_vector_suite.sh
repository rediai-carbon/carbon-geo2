#!/bin/bash
# Full Geo2 vector unittest module through the accepted Blue exefile runtime (Fenris lane).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GEO2_REPO_ROOT="${GEO2_REPO_ROOT:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
FENRIS_GEO2_SUITE_ROOT="${FENRIS_GEO2_SUITE_ROOT:-$(mktemp -d "${TMPDIR:-/tmp}/fenris-geo2-suite-XXXXXX")}"
export FENRIS_GEO2_WORK_ROOT="${FENRIS_GEO2_WORK_ROOT:-$FENRIS_GEO2_SUITE_ROOT/port-work}"
export FENRIS_GEO2_STAGE_DIR="${FENRIS_GEO2_STAGE_DIR:-$FENRIS_GEO2_SUITE_ROOT/stage}"
mkdir -p "$FENRIS_GEO2_STAGE_DIR/lib"
cleanup() {
  if [ "${FENRIS_GEO2_CLEANUP:-1}" = "1" ]; then
    rm -rf "$FENRIS_GEO2_SUITE_ROOT" 2>/dev/null || true
  fi
}
trap cleanup EXIT

bash "$SCRIPT_DIR/geo2_port_install_from_registry.sh"
BLUE_PREFIX="${FENRIS_BLUE_PREFIX:-/work/build-registry/vcpkg_installed/x64-linux-release}"
BUILD="${FENRIS_BLUE_BUILD:-/work/build-registry}"
EXEFILE="${FENRIS_EXEFILE:-$BLUE_PREFIX/tools/carbon-exefile/exefile}"
test -x "$EXEFILE"
GEO2_SO="${FENRIS_GEO2_INSTALL_PREFIX:?}/lib/_geo2.so"
test -f "$GEO2_SO"
install -m 0644 "$GEO2_SO" "$FENRIS_GEO2_STAGE_DIR/lib/_geo2.so"
# Never modify or delete artifacts under the accepted Blue prefix in default (isolated) mode.
export LD_LIBRARY_PATH="$FENRIS_GEO2_STAGE_DIR/lib:$BUILD:$BLUE_PREFIX/lib"
export PYTHONPATH="$FENRIS_GEO2_STAGE_DIR/lib:$BUILD:$BLUE_PREFIX/lib:$BLUE_PREFIX/bin:$BLUE_PREFIX/bin/python:$BLUE_PREFIX/lib/python3.12:${GEO2_REPO_ROOT}/python"
export GEO2_STAGE_LIB="$FENRIS_GEO2_STAGE_DIR/lib"
"$EXEFILE" /nocrashreportupload /buildflavor=release /py -c '
import os, sys, blue, geo2, importlib.util
stage = os.environ["GEO2_STAGE_LIB"]
spec = importlib.util.find_spec("_geo2")
assert spec and spec.origin
origin = os.path.realpath(spec.origin)
assert origin.startswith(os.path.realpath(stage)), (origin, stage)
v = geo2.VectorD(1.0, 2.0, 3.0)
assert tuple(v / 2.0) == (0.5, 1.0, 1.5)
libpy = {line.split()[-1] for line in open("/proc/self/maps") if "libpython" in line}
assert len(libpy) == 1
print("GEO2_BLUE_LOAD", origin)
print("LIBPYTHON", sorted(libpy)[0])
'
UT_LOG="$FENRIS_GEO2_SUITE_ROOT/vector-unittest.log"
set +e
"$EXEFILE" /nocrashreportupload /buildflavor=release /py "$GEO2_REPO_ROOT/python/geo2/test/test_geo2Vector3.py" 2>&1 | tee "$UT_LOG"
UT_EXIT=${PIPESTATUS[0]}
set -e
grep -E '^Ran |^OK|^FAILED|skipped' "$UT_LOG" || true
if [ "$UT_EXIT" -ne 0 ]; then
  echo "GEO2_VECTOR_UNITTEST_EXIT=$UT_EXIT"
  exit "$UT_EXIT"
fi
grep -q '^OK' "$UT_LOG"
echo GEO2_BLUE_VECTOR_SUITE_OK