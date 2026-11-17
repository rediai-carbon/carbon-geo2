# Linux

Preset `x64-linux-release` uses the registry triplet `x64-linux-release`.

The Carbon registry pin is branch `fe4/core-lane-b-modernized` at `a412b804ced9a381efea7487b982b53d13ca5ab1`. This vcpkg tool reads the default branch when `reference` is omitted, so the branch name is part of the pin. That branch is not registry `main`.

The Math port on that pin fetches `https://github.com/carbonengine/math.git` at `540edbfbb779a8f5616e9bbdfbf595c564af5a2c`.

This tree has no CTest target. The Linux check is configure and build of `_geo2.so`.
