# Geo2 Linux integration scripts

## Pins

`fenris_registry_pins.sh` documents the expected **registry git SHA** and **Geo2 source revision** (`19c5ea9` / `72d8992` / port `2.1.2#2` after Registry PR #12). Override with `GEO2_REGISTRY_SHA` when testing a PR branch.

## Direct installed consumer

`geo2_port_install_from_registry.sh` validates port **`2.1.2#2`**, source ref, `RUNPATH`, single `libpython` NEEDED, and runs `examples/installed_consumer.py`.

## Blue vector suite (functional)

`linux_blue_vector_suite.sh` stages `_geo2.so` under `/tmp/fenris-geo2-blue-stage` by default (`FENRIS_GEO2_INSTALL_IN_BLUE_PREFIX=1` copies into Blue prefix). Runs all **24** tests in `python/geo2/test/test_geo2Vector3.py` (three historical skips); **nonzero exit** on failure.

Requires Fenris `fe-linux-fresh` + `carbon-linux-gcc-buildenv:fe1`.

GitHub Actions validates **shell syntax and pin constants only**; it does **not** prove 21 passing vector tests.