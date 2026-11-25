"""Import an installed _geo2 extension and exercise its public geometry calls."""

import sys

import _geo2


def close(actual, expected, label, tolerance=1.0e-5):
    if len(actual) != len(expected):
        raise SystemExit(f"{label} length {len(actual)} != {len(expected)}: {actual}")
    for index, (left, right) in enumerate(zip(actual, expected)):
        if abs(float(left) - float(right)) > tolerance:
            raise SystemExit(f"{label}[{index}] {left} != {right} in {actual}")


def main():
    added = _geo2.Vec3Add((1.0, 2.0, 3.0), (4.0, 5.0, 6.0))
    close(added, (5.0, 7.0, 9.0), "Vec3Add")

    dot = _geo2.Vec3Dot((1.0, 0.0, 0.0), (0.0, 1.0, 0.0))
    dot_value = float(dot if isinstance(dot, (int, float)) else dot[0])
    if abs(dot_value) > 1.0e-5:
        raise SystemExit(f"Vec3Dot {dot}")

    identity = _geo2.QuaternionIdentity()
    close(identity, (0.0, 0.0, 0.0, 1.0), "QuaternionIdentity")
    close(_geo2.QuaternionInverse(identity), identity, "QuaternionInverse")
    close(_geo2.QuaternionMultiply(identity, identity), identity, "QuaternionMultiply")

    matrix = _geo2.MatrixRotationQuaternion(identity)
    close(_geo2.QuaternionRotationMatrix(matrix), identity, "QuaternionRotationMatrix")

    invalid = None
    try:
        _geo2.Vec3Add(1, 2)
    except Exception as error:
        invalid = type(error).__name__
    if invalid is None:
        raise SystemExit("Vec3Add accepted invalid input")

    print(
        "GEO2_CONSUMER "
        f"add={tuple(float(v) for v in added)} "
        f"dot={dot_value} "
        f"quat={tuple(float(v) for v in identity)} "
        f"matrix={len(matrix)} "
        f"invalid={invalid} "
        f"python={sys.version.split()[0]}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
