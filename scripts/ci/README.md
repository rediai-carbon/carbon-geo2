# Geo2 Linux integration scripts

## Direct installed consumer

`geo2_port_install_from_registry.sh` installs `carbon-geo2` from `carbon-vcpkg-registry` and runs `examples/installed_consumer.py`.

Environment:

- `FENRIS_VCPKG_ROOT` — vcpkg clone (e.g. `/work/vcpkg`)
- `FENRIS_REGISTRY_ROOT` — checkout of `carbon-vcpkg-registry` (overlay triplets/toolchains)
- `GEO2_REGISTRY_SHA` — registry git ref (default: current registry `main`)
- `GEO2_REPO_ROOT` — this repository (default: auto)

## Blue vector suite

`linux_blue_vector_suite.sh` co-installs `_geo2.so` into the Blue prefix, runs `blue.LoadExtension`, and executes `python/geo2/test/test_geo2Vector3.py` through `exefile`.

Additional environment:

- `FENRIS_BLUE_BUILD` — Blue CMake build dir with `blue.so` (default `/work/build-registry`)
- `FENRIS_BLUE_PREFIX` — Blue vcpkg installed triplet prefix

Designed for the Fenris `carbon-linux-gcc-buildenv:fe1` image and `fe-linux-fresh` volume; not self-contained on pristine `ubuntu-latest` without those artifacts.