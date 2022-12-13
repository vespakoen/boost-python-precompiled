# boost-python-precompiled

This project compiles Boost.Python for Windows, Linux and macOS, the most common architectures and Python versions 3.7, 3.8, 3.9, 3.10 and 3.11.

## How it works

We leverage / abuse cibuildwheel because it can easily setup all python versions for us.
That is why there is a "dummy" python package, a setup.py and pyproject.toml in here.
We use cibuildwheel's `before-build` option to make it compile Boost.Python and copy out the compiled Boost.Python at the end.