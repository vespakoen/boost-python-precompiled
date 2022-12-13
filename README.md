[![CD](https://github.com/vespakoen/boost-python-precompiled/actions/workflows/cd.yml/badge.svg)](https://github.com/vespakoen/boost-python-precompiled/actions/workflows/cd.yml)

# boost-python-precompiled

This project compiles Boost.Python for Windows, Linux and macOS, the most common architectures and Python versions 3.7 - 3.11.

|         | Architectures          | Python       |
|---------|------------------------|--------------|
| Windows | x86-32, x86-64, arm-64 | v3.7 - v3.11 |
| Linux   | x86-64, arm-64         | v3.7 - v3.11 |
| macOS   | x86-64, arm-64         | v3.7 - v3.11 |

The libraries are compiled with `variant="debug,release"`, `link="static"` and `cxxflags="-fPIC"`, making them suitable for static linking only.

## How it works

We leverage / "abuse" cibuildwheel because it can easily setup all Python versions for us, and compiles in images with an old Glibc version for older linux versions compatibility.
That is also the reason why there is a "dummy" python package, a setup.py and pyproject.toml in here.
We use cibuildwheel's `before-build` option to make it compile Boost.Python and copy out the compiled Boost.Python at the end.

## Miscellaneous

We also include a patch for Boost.Python that fixes v3.11 compatibility.
This issue is solved in upstream Boost.Python, but not merged yet.

See: https://github.com/boostorg/python/pull/385

## Downloads

The downloads are available on the [Releases](https://github.com/vespakoen/boost-python-precompiled/releases) page.

## License

The repository code is released under MIT License

Boost binaries and Boost sources are licensed under standard Boost license.