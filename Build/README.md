#Build Scripts

This directory contains a series of shell scripts to be run at different intervals during the build process:

- Scripts prefixed with `before_` are intended to be first in order to setup any necessary dependencies.

- Scripts prefixed with `after_` are intended to be run after the build to do any post-process reporting.

- Scripts without a decerning prefix are intended to be run as part of the actual build process.

All of these scripts are intended to be run from the root directory of this source code repository, e.g. as `./Build/<build-script>.sh`.

The `./build.sh` script can be used in the top-level directory to run the whole build process, otherwise the project should be built on push, by the [Travis CI server](https://travis-ci.org/ice3-software/between-kit).
